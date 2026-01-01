import { Express, Request, Response } from 'express';
import { getScripts, getScript } from './services/scriptService';
import { executeScript, getExecution, getAllExecutions } from './services/executionService';
import { getSystemInfo } from './services/systemService';

export function setupRoutes(app: Express): void {
  // System information
  app.get('/api/system/info', async (req: Request, res: Response) => {
    try {
      const info = await getSystemInfo();
      res.json(info);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get system info' });
    }
  });

  // Scripts
  app.get('/api/scripts', async (req: Request, res: Response) => {
    try {
      const platform = req.query.platform as string | undefined;
      const scripts = await getScripts(platform);
      res.json(scripts);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get scripts' });
    }
  });

  app.get('/api/scripts/:id', async (req: Request, res: Response) => {
    try {
      const script = await getScript(req.params.id);
      if (!script) {
        res.status(404).json({ error: 'Script not found' });
        return;
      }
      res.json(script);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get script' });
    }
  });

  // Executions
  app.post('/api/execute', async (req: Request, res: Response) => {
    try {
      const { scriptId, options } = req.body;
      if (!scriptId) {
        res.status(400).json({ error: 'Script ID is required' });
        return;
      }
      const execution = await executeScript(scriptId, options);
      res.json(execution);
    } catch (error) {
      res.status(500).json({ error: 'Failed to execute script' });
    }
  });

  app.get('/api/executions', async (req: Request, res: Response) => {
    try {
      const executions = await getAllExecutions();
      res.json(executions);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get executions' });
    }
  });

  app.get('/api/executions/:id', async (req: Request, res: Response) => {
    try {
      const execution = await getExecution(req.params.id);
      if (!execution) {
        res.status(404).json({ error: 'Execution not found' });
        return;
      }
      res.json(execution);
    } catch (error) {
      res.status(500).json({ error: 'Failed to get execution' });
    }
  });
}
