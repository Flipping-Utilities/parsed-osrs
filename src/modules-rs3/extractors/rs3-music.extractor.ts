import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_MUSIC } from "../../constants/rs3-paths";
import { MusicTrack } from "../../types";
import { PageTags } from "../../constants/tags";
import { parseMusicFromContent } from "../../modules/extractors/music.extractor";
import { Rs3PageContentDumper } from "../dumpers/rs3-page-content.dumper";
import { Rs3PageListDumper } from "../dumpers/rs3-page-list.dumper";

/**
 * Origin of the RS3 wiki. The OSRS `parseMusicFromContent` hardcodes
 * `https://oldschool.runescape.wiki` into `fileUrl`; we rewrite the host in
 * post-processing so RS3 media URLs resolve on the RS3 site.
 */
const OSRS_WIKI_ORIGIN = "https://oldschool.runescape.wiki";
const RS3_WIKI_ORIGIN = "https://runescape.wiki";

/** RS3 counterpart of {@link MusicExtractor}. */
@Injectable()
export class Rs3MusicExtractor {
  private logger = new Logger(Rs3MusicExtractor.name);
  private cachedTracks: MusicTrack[] | null = null;

  constructor(
    private readonly pageListDumper: Rs3PageListDumper,
    private readonly pageContentDumper: Rs3PageContentDumper,
  ) {}

  public async extractAllMusic(): Promise<MusicTrack[]> {
    this.logger.log("Start: Extracting music tracks (RS3)");

    const pages = await this.pageListDumper.getPagesFromTag(PageTags.MUSIC);
    const length = pages.length;
    const tracks: MusicTrack[] = [];
    let i = 0;
    for await (const page of pages) {
      if (i++ % 50 === 0) {
        this.logger.debug(`Music: ${i}/${length}`);
      }
      const track = await this.extractMusicFromPageId(page.id);
      if (track) tracks.push(track);
    }

    tracks.sort((a, b) => a.name.localeCompare(b.name));
    if (tracks.length) {
      writeFileSync(ALL_MUSIC, JSON.stringify(tracks, null, 2));
    }

    this.logger.log("Done: Extracting music tracks (RS3)");
    return tracks;
  }

  public getAllMusic(): MusicTrack[] | null {
    if (!this.cachedTracks) {
      if (!existsSync(ALL_MUSIC)) {
        return null;
      }
      try {
        this.cachedTracks = JSON.parse(readFileSync(ALL_MUSIC, "utf8"));
      } catch (e) {
        this.logger.warn("all music has invalid content", e);
      }
    }
    return this.cachedTracks;
  }

  private async extractMusicFromPageId(pageId: number): Promise<MusicTrack | null> {
    const page = await this.pageContentDumper.getDBPageFromId(pageId);
    if (!page || !page.text) {
      return null;
    }
    const track = parseMusicFromContent(page.text, page.title, page.aliases || []);
    if (track?.fileUrl) {
      track.fileUrl = track.fileUrl.replace(OSRS_WIKI_ORIGIN, RS3_WIKI_ORIGIN);
    }
    return track;
  }
}
