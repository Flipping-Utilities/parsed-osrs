# Wiki Scraper

Project to download all of the wiki page, and extract a lot of metadata from it.

## THIS IS A WORK IN PROGRESS!
It's something I've used to extract some information from the wiki, but is very much not ready for production use. As I've been lacking the time to clean everything up, I'm still releasing it so it can be used by others.

If you'd like to contribute to the project, please message me on discord `Anyny0#4452` in `discord.gg/flipping` so we can chat!  
I'll be slowly working on this project so it can gather all of the information required: My end goal is to have everything be available as a json, then in a database, and expose a GraphQL endpoint where we can query anything related to OSRS from it.

CREDIT to the OSRS wiki!
All of the content extracted from the wiki belongs to Jagex and the OSRS wiki team, this is only an interface to parse the data.

## Usage

There are 2 environment variables you can set:  
`DATA_FOLDER_PATH`, which will contain the resulting parsed data, and `WIKI_FOLDER_PATH`, which will contain the raw wiki dumped data.  
They default to `./data` and `./wiki-data`, you will have to create the `wiki-data` directory to get started.

At this time, everything works through the `DevService` within `./src/modules/app/dev.service.ts`: It defaults to `dumpEverything`, which will download every single wiki page, then extract all of the information from them.

Downloading all of the wiki pages take a while, so I would recommend only doing it every major update or whenevery you need the most up-to-date data. If you want to use the local files, replace `this.dumpEverything()`  with `this.extractWikiContent()` within the dev service method, or adjust as you need to only dump the relevant data you need.

To run:
1. Make sure the environment variables are set, or that the `wiki-data` folder exists.
2. Adjust the dev service content to dump or extract the relevant data only
3. Run using `npm run start`