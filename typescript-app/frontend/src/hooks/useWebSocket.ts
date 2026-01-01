import { useCallback, useRef } from 'react';
import { useExecutionStore } from '../store/executionStore';
import { WebSocketMessage } from '../types';

const WS_URL = 'ws://localhost:3001';

export function useWebSocket() {
  const wsRef = useRef<WebSocket | null>(null);
  const { addLog, updateExecution } = useExecutionStore();

  const connect = useCallback(() => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      return;
    }

    const ws = new WebSocket(WS_URL);
    wsRef.current = ws;

    ws.onopen = () => {
      console.log('✅ WebSocket connected');
    };

    ws.onmessage = (event) => {
      try {
        const message: WebSocketMessage = JSON.parse(event.data);

        switch (message.type) {
          case 'log':
            if (message.executionId) {
              addLog(message.executionId, message.data.log);
            }
            break;
          case 'execution_update':
            updateExecution(message.data);
            break;
          case 'connected':
            console.log('Connected with client ID:', message.clientId);
            break;
          case 'pong':
            console.log('Pong received');
            break;
        }
      } catch (error) {
        console.error('Error parsing WebSocket message:', error);
      }
    };

    ws.onerror = (error) => {
      console.error('❌ WebSocket error:', error);
    };

    ws.onclose = () => {
      console.log('🔌 WebSocket disconnected');
      // Attempt to reconnect after 3 seconds
      setTimeout(() => {
        console.log('🔄 Attempting to reconnect...');
        connect();
      }, 3000);
    };
  }, [addLog, updateExecution]);

  const disconnect = useCallback(() => {
    if (wsRef.current) {
      wsRef.current.close();
      wsRef.current = null;
    }
  }, []);

  const send = useCallback((message: any) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify(message));
    }
  }, []);

  return { connect, disconnect, send };
}
