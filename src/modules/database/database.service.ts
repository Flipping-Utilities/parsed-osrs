import { createClient } from '@libsql/client';
import { Injectable } from '@nestjs/common';
import { drizzle } from 'drizzle-orm/libsql';
import * as path from 'path';
import * as schema from './schema';

@Injectable()
export class DatabaseService {
  private db: ReturnType<typeof drizzle<typeof schema>>;

  constructor() {
    const dbPath = path.join(process.cwd(), process.env.DB_PATH as string);
    const client = createClient({
      url: `file:/${dbPath}`,
    });

    this.db = drizzle(client, { schema });
  }

  getDb() {
    return this.db;
  }
}
