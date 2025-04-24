// app.js


require('dotenv').config(); // 맨 위에 추가
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000; // .env에서 불러옴

app.get('/', (req, res) => {
  res.send('방토리 서버가 잘 작동 중입니다!');
});

app.listen(PORT, () => {
  console.log(`서버가 http://localhost:${PORT} 에서 실행 중입니다`);
});
