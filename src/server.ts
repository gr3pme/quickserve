import * as http from 'http';
import * as os from 'os';

interface ServerOptions {
  port: number;
  host: string;
}

interface HealthStatus {
  status: 'healthy' | 'degraded' | 'unhealthy';
  uptime: number;
  timestamp: string;
  system: {
    platform: string;
    arch: string;
    nodeVersion: string;
    memory: {
      total: number;
      free: number;
      usedPercent: number;
    };
    cpuLoad: number[];
  };
}

/**
 * Build the health status payload
 */
function getHealthStatus(startTime: number): HealthStatus {
  const totalMem = os.totalmem();
  const freeMem = os.freemem();

  return {
    status: 'healthy',
    uptime: Math.floor((Date.now() - startTime) / 1000),
    timestamp: new Date().toISOString(),
    system: {
      platform: os.platform(),
      arch: os.arch(),
      nodeVersion: process.version,
      memory: {
        total: Math.round(totalMem / 1024 / 1024),
        free: Math.round(freeMem / 1024 / 1024),
        usedPercent: Math.round(((totalMem - freeMem) / totalMem) * 100),
      },
      cpuLoad: os.loadavg(),
    },
  };
}

/**
 * Create and start the dev server with health endpoint
 */
export function createServer(options: ServerOptions): http.Server {
  const startTime = Date.now();

  const server = http.createServer((req, res) => {
    const url = req.url || '/';

    if (url === '/health' || url === '/healthz') {
      const health = getHealthStatus(startTime);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(health, null, 2));
      return;
    }

    if (url === '/ready') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ ready: true }));
      return;
    }

    if (url === '/') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        name: 'quickserve',
        version: '1.2.0',
        endpoints: ['/health', '/healthz', '/ready'],
      }));
      return;
    }

    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  });

  server.listen(options.port, options.host, () => {
    console.log(`\n  quickserve v1.2.0\n`);
    console.log(`  Local:   http://localhost:${options.port}`);
    console.log(`  Health:  http://localhost:${options.port}/health`);
    console.log(`  Ready:   http://localhost:${options.port}/ready\n`);
  });

  return server;
}
