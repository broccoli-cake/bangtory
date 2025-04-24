exports.getUsers = (req, res) => {
    const users = [
      { id: 1, name: "Alice" },
      { id: 2, name: "Bob" }
    ];
    res.json(users);
  };