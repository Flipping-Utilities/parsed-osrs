import 'dotenv/config';
import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './modules/app/app.module';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  await app.init();
}
bootstrap();

process
  .on('unhandledRejection', (reason, p) => {
    Logger.error(reason, 'Unhandled Rejection at Promise', p);
  })
  .on('uncaughtException', (err) => {
    Logger.error(err, 'Uncaught Exception thrown');
    process.exit(1);
  });
