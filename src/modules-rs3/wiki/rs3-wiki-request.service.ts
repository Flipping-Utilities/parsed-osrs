import { Injectable } from "@nestjs/common";
import { WikiRequestService } from "../../modules/wiki/wikiRequest.service";

/**
 * RS3-flavoured {@link WikiRequestService}.
 *
 * Targets the RuneScape Wiki at `https://runescape.wiki` instead of the OSRS
 * subdomain. Everything else (throttle, retries, batching, pagination) is
 * inherited unchanged from the parent class so behaviour stays consistent
 * across both games.
 *
 * The Discord User-Agent label is `rs3` to let the wiki operators distinguish
 * traffic from the two scrapers.
 *
 * Implementation note: origin + label are provided via `resolveWikiOrigin()`
 * / `resolveUserAgentLabel()` overrides rather than via `super(...)` args so
 * that NestJS DI doesn't try to inject `String` tokens into the parent
 * constructor. Methods are virtually dispatched even when called from the
 * parent constructor.
 */
@Injectable()
export class Rs3WikiRequestService extends WikiRequestService {
  protected resolveWikiOrigin(): string {
    return "https://runescape.wiki";
  }

  protected resolveUserAgentLabel(): string {
    return "rs3";
  }
}
