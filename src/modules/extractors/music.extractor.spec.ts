import { loadTestPage, type TestPage } from '../../../test/test-utils';
import { TestPages } from '../../constants/test-pages';
import { parseMusicFromContent } from './music.extractor';

describe('parseMusicFromContent', () => {
  it('parses the Adventure music track metadata, file URL, and region polygon', () => {
    const page = loadTestPage(TestPages.Adventure);
    const track = parseMusicFromContent(page.text, page.title, page.aliases);

    expect(track).not.toBeNull();
    expect(track!.name).toBe('Adventure');
    expect(track!.members).toBe(false);
    expect(track!.number).toBe(1);
    expect(track!.cacheId).toBe(177);
    expect(track!.fileName).toBe('Adventure.ogg');
    expect(track!.fileUrl).toBe(
      'https://oldschool.runescape.wiki/w/Special:FilePath/Adventure.ogg'
    );
    expect(track!.location).toBe('Varrock');
    expect(track!.hint).toBe('This track unlocks in Varrock.');
    expect(track!.quest).toBe('No');
    expect(track!.composer).toBe('Ian Taylor');
    expect(track!.duration).toBe('02:34');
    expect(track!.tempo).toBe('124 BPM');
    expect(track!.signature).toBe('4/4');
    expect(track!.sortName).toBe('Adventure');
    expect(track!.instruments).toContain('Acoustic Grand Piano');
    expect(track!.instruments).toContain('Percussion');
    expect(track!.unlockDetail).toContain('Unlocked inside');

    // Polygon parsed from the inline {{Map|...|mtype=polygon|...}}
    expect(track!.polygon).toBeDefined();
    expect(track!.polygon!.vertices).toHaveLength(4);
    expect(track!.polygon!.centroid).toEqual({ x: 3232, y: 3488 });
  });

  it('returns null for a page with no music infobox', () => {
    const page = loadTestPage(TestPages.StoneBowl);
    expect(
      parseMusicFromContent(page.text, page.title, page.aliases)
    ).toBeNull();
  });
});
