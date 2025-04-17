import { Injectable, OnModuleInit } from '@nestjs/common';
import { drizzle } from 'drizzle-orm/libsql';
import { createClient } from '@libsql/client';
import * as schema from './schema';
import * as path from 'path';

@Injectable()
export class DatabaseService {
  private db: ReturnType<typeof drizzle<typeof schema>>;

  constructor() {
    const dbPath = path.join(process.cwd(), process.env.DB_PATH);
    const client = createClient({
      url: `file:/${dbPath}`,
    });

    this.db = drizzle(client, { schema });
  }

  getDb() {
    return this.db;
  }
}
