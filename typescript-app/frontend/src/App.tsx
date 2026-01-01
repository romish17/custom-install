import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Scripts from './pages/Scripts';
import Executions from './pages/Executions';
import { useWebSocket } from './hooks/useWebSocket';
import { useEffect } from 'react';

function App() {
  const { connect, disconnect } = useWebSocket();

  useEffect(() => {
    connect();
    return () => disconnect();
  }, [connect, disconnect]);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="scripts" element={<Scripts />} />
          <Route path="executions" element={<Executions />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
