CREATE TABLE IF NOT EXISTS unread_messages (
  user_jid VARCHAR(255) NOT NULL,
  conversation_jid VARCHAR(255) NOT NULL,
  message_id BIGINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  PRIMARY KEY (user_jid, conversation_jid, message_id)
);

