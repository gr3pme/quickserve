#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import { createServer } from './server';

const program = new Command();

program
  .name('quickserve')
  .description('Lightweight local dev server with health checks')
  .version('1.2.0');

program
  .command('serve')
  .description('Start the development server')
  .option('-p, --port <port>', 'Port number', '3000')
  .option('-H, --host <host>', 'Host to bind', '127.0.0.1')
  .action((options) => {
    const port = parseInt(options.port, 10);
    console.log(chalk.blue('Starting quickserve...'));
    createServer({ port, host: options.host });
  });

program
  .command('health')
  .description('Check health of a running instance')
  .option('-p, --port <port>', 'Port to check', '3000')
  .action(async (options) => {
    try {
      const http = await import('http');
      const req = http.get(`http://localhost:${options.port}/health`, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          const health = JSON.parse(data);
          if (health.status === 'healthy') {
            console.log(chalk.green('✓ Server is healthy'));
            console.log(chalk.dim(`  Uptime: ${health.uptime}s`));
            console.log(chalk.dim(`  Memory: ${health.system.memory.usedPercent}% used`));
          } else {
            console.log(chalk.yellow(`⚠ Server status: ${health.status}`));
          }
        });
      });
      req.on('error', () => {
        console.log(chalk.red('✗ Server is not running'));
        process.exit(1);
      });
    } catch (error) {
      console.error(chalk.red('Error checking health:'), error);
      process.exit(1);
    }
  });

program.parse();
