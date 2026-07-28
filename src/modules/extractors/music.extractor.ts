import { Injectable, Logger } from "@nestjs/common";
import { existsSync, readFileSync, writeFileSync } from "fs";
import { ALL_MUSIC } from "../../constants/paths";
import { MusicTrack } from "../../types";
import { PageContentDumper, PageListDumper } from "../dumpers";
import { PageTags } from "../../constants/tags";
import { parseWikitext } from "../../utils/wikitext-parser";
import { parseMapTemplate } from "../../utils/map-parser";
import { parseListValue, wikiBool, wikiNumber, wikiString } from "../../utils/wiki-coercion";

const WIKI_BASE = "https://oldschool.runescape.wiki";
const FILE_PATH_BASE = `${WIKI_BASE}/w/Special:FilePath`;

/**
 * Extracts a clean filename from a wiki `file` infobox value.
 *
 * The infobox stores the audio reference as a `[[File:Adventure.ogg]]` link.
 * `wikiString` strips `[[File:...]]` entirely, so this helper pulls the raw
 * filename out of the original markup (handling `[[File:X]]`, `File:X`, and
 * bare `X`).
 */
function extractFileName(raw: unknown): string | undefined {
  if (raw === null || raw === undefined) return undefined;
  let str = String(raw).trim();
  if (!str) return undefined;
  const fileLinkMatch = str.match(/\[\[\s*File:\s*([^\]|]+)/i);
  if (fileLinkMatch) {
    str = fileLinkMatch[1];
  } else {
    str = str.replace(/^\s*File:\s*/i, "");
  }
  str = str.trim().replace(/\s+/g, "_");
  return str || undefined;
}

/**
 * Builds a stable remote URL for a wiki media filename. Uses the
 * `Special:FilePath` redirection which is unaffected by hash changes.
 */
function buildFileUrl(fileName: string | undefined): string | undefined {
  if (!fileName) return undefined;
  return `${FILE_PATH_BASE}/${fileName}`;
}

export function parseMusicFromContent(
  pageText: string,
  pageTitle: string,
  pageAliases: string[],
): MusicTrack | null {
  const parsed = parseWikitext(pageText);
  const data = parsed.getInfobox("music");
  if (!data) return null;

  const fileName = extractFileName(data.file);

  const track: MusicTrack = {
    name: wikiString(data.name) || pageTitle,
    aliases: pageAliases,
    members: wikiBool(data.members),
  };

  const number = wikiNumber(data.number, NaN);
  if (Number.isFinite(number) && number > 0) track.number = number;

  if (fileName) {
    track.fileName = fileName;
    track.fileUrl = buildFileUrl(fileName);
  }

  const cacheId = wikiNumber(data.cacheid, NaN);
  if (Number.isFinite(cacheId) && cacheId > 0) track.cacheId = cacheId;

  if (data.release) track.release = wikiString(data.release);
  if (data.update) track.update = wikiString(data.update);
  if (data.location) track.location = wikiString(data.location);
  if (data.hint) track.hint = wikiString(data.hint);
  if (data.quest) track.quest = wikiString(data.quest);
  if (data.event) track.event = wikiString(data.event);
  if (data.duration) track.duration = wikiString(data.duration);
  if (data.tempo) track.tempo = wikiString(data.tempo);
  if (data.signature) track.signature = wikiString(data.signature);
  if (data.composer) track.composer = wikiString(data.composer);
  if (data.album) track.album = wikiString(data.album);
  if (data.sortname) track.sortName = wikiString(data.sortname);
  if (data.unlockdetail) track.unlockDetail = wikiString(data.unlockdetail);

  const instruments = parseListValue(data.instruments)
    .map((s) => wikiString(s))
    .filter(Boolean);
  if (instruments.length) track.instruments = instruments;

  const platform = parseListValue(data.platform)
    .map((s) => wikiString(s))
    .filter(Boolean);
  if (platform.length) track.platform = platform;

  // An inline {{Map|...}} on the page marks where the track plays/unlocks.
  // Prefer a polygon (region boundary) and fall back to a point marker.
  for (const mapTemplate of parsed.getTemplates("map")) {
    const map = parseMapTemplate(mapTemplate);
    if (map?.polygon) {
      track.polygon = map.polygon;
      break;
    }
  }
  if (!track.polygon) {
    for (const mapTemplate of parsed.getTemplates("map")) {
      const map = parseMapTemplate(mapTemplate);
      if (map?.point) {
        track.position = map.point;
        break;
      }
    }
  }

  return track;
}

@Injectable()
export class MusicExtractor {
  private logger = new Logger(MusicExtractor.name);
  private cachedTracks: MusicTrack[] | null = null;

  constructor(
    private readonly pageListDumper: PageListDumper,
    private readonly pageContentDumper: PageContentDumper,
  ) {}

  public async extractAllMusic(): Promise<MusicTrack[]> {
    this.logger.log("Start: Extracting music tracks");

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

    this.logger.log("Done: Extracting music tracks");
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
    return parseMusicFromContent(page.text, page.title, page.aliases || []);
  }
}
