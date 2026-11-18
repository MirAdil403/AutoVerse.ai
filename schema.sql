CREATE TABLE IF NOT EXISTS inquiries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL, phone TEXT NOT NULL, email TEXT, service TEXT, business TEXT, message TEXT,
  ip_hash TEXT NOT NULL, created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_inq_ip_time ON inquiries (ip_hash, created_at);
