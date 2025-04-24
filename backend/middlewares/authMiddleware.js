exports.auth = (req, res, next) => {
    const isLoggedIn = true; // 실제로는 토큰 검사 등을 함
  
    if (!isLoggedIn) {
      return res.status(401).json({ message: "Unauthorized" });
    }
  
    next(); // 다음 단계로 넘어감 (ex. 컨트롤러)
  };