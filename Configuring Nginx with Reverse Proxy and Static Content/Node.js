const express = require('express');
const app = express();

app.get('/api/data', (req, res) => {
    res.json({ message: 'Hello from the backend!' });
});

app.listen(3000, () => {
    console.log('Backend listening on port 3000');
});
