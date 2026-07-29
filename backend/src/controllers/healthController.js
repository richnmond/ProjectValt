const getHealthStatus = (req, res) => {
  res.json({
    status: 'ok',
    service: 'projectvault-backend',
    timestamp: new Date().toISOString(),
  });
};

module.exports = {
  getHealthStatus,
};
