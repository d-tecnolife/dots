from __future__ import annotations

import os
import re
import tempfile
from collections.abc import Iterable

import musicbrainzngs
import requests

from beets.plugins import BeetsPlugin
from beets.util import syspath
from beetsplug._utils import art

MBID_RE = re.compile(r"([0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12})")


class SingletonCoverArtPlugin(BeetsPlugin):
    def __init__(self):
        super().__init__()
        self.config.add(
            {
                "ifempty": True,
                "max_releases": 8,
                "image_size": 500,
                "request_timeout": 15,
            }
        )
        musicbrainzngs.set_useragent("beets-singletoncoverart", "1.0", "")
        self.register_listener("import_task_files", self.import_task_files)

    def _normalize_mbid(self, value: str | None) -> str | None:
        if not value:
            return None
        if match := MBID_RE.search(value):
            return match.group(1).lower()
        return None

    def _release_ids_for_track(self, track_mbid: str) -> list[str]:
        try:
            data = musicbrainzngs.get_recording_by_id(
                track_mbid, includes=["releases"]
            )
        except Exception as exc:
            self._log.debug(
                "singletoncoverart: failed MB lookup for {}: {}",
                track_mbid,
                exc,
            )
            return []
        recording = data.get("recording", {})
        releases: Iterable[dict] = recording.get("release-list", [])
        ids: list[str] = []
        for release in releases:
            release_id = release.get("id")
            if isinstance(release_id, str):
                ids.append(release_id)
        return ids

    def _download_release_cover(self, release_id: str) -> str | None:
        timeout = self.config["request_timeout"].get(int)
        size = self.config["image_size"].get(int)
        cover_url = f"https://coverartarchive.org/release/{release_id}/front-{size}"
        try:
            resp = requests.get(cover_url, timeout=timeout)
        except requests.RequestException as exc:
            self._log.debug(
                "singletoncoverart: request failed for {}: {}", cover_url, exc
            )
            return None
        if resp.status_code != 200:
            return None

        content_type = resp.headers.get("Content-Type", "").lower()
        suffix = ".png" if "png" in content_type else ".jpg"
        fd, tmp_path = tempfile.mkstemp(prefix="beets-singleton-art-", suffix=suffix)
        with os.fdopen(fd, "wb") as handle:
            handle.write(resp.content)
        return tmp_path

    def import_task_files(self, session, task):
        if task.is_album:
            return

        item = getattr(task, "item", None)
        if item is None:
            return
        if not os.path.isfile(syspath(item.path)):
            return

        if self.config["ifempty"].get(bool) and art.get_art(self._log, item):
            return

        track_mbid = self._normalize_mbid(getattr(item, "mb_trackid", None))
        if not track_mbid:
            return

        release_ids = self._release_ids_for_track(track_mbid)
        if not release_ids:
            return

        max_releases = self.config["max_releases"].get(int)
        for release_id in release_ids[:max_releases]:
            tmp_path = self._download_release_cover(release_id)
            if not tmp_path:
                continue
            try:
                art.embed_item(
                    self._log,
                    item,
                    tmp_path,
                    ifempty=self.config["ifempty"].get(bool),
                )
                self._log.info(
                    "singletoncoverart: embedded art for {} using release {}",
                    item,
                    release_id,
                )
                return
            finally:
                try:
                    os.remove(tmp_path)
                except OSError:
                    pass
