-- based on postgresql

---------------------
-- database design
---------------------


-- 删除现有表（如果存在）
DROP TABLE IF EXISTS feedback, security_events, device_usage, devices, rooms, user_homes, users;

-- 用户表
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    full_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE
);

-- 用户住宅信息表
CREATE TABLE user_homes (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    address TEXT,
    area FLOAT,
    city VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    timezone VARCHAR(50) DEFAULT 'UTC'
);

-- 房间表
CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    home_id INTEGER REFERENCES user_homes(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    room_type VARCHAR(50) NOT NULL, -- 如: living room, bedroom, kitchen等
    floor INTEGER,
    area FLOAT
);

-- 设备表
CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    room_id INTEGER REFERENCES rooms(id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) NOT NULL, -- 如: light, thermostat, camera等
    model VARCHAR(100),
    manufacturer VARCHAR(100),
    serial_number VARCHAR(100),
    ip_address VARCHAR(15),
    mac_address VARCHAR(17),
    firmware_version VARCHAR(50),
    is_online BOOLEAN DEFAULT FALSE,
    last_seen TIMESTAMP,
    power_consumption FLOAT, -- 瓦特
    installation_date DATE,
    status VARCHAR(20) DEFAULT 'active' -- active, maintenance, disabled
);

-- 设备使用记录表
CREATE TABLE device_usage (
    id SERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(id) ON DELETE CASCADE,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration INTERVAL GENERATED ALWAYS AS (end_time - start_time) STORED,
    energy_consumption FLOAT, -- 千瓦时
    operation_mode VARCHAR(50),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- 安防事件表
CREATE TABLE security_events (
    id SERIAL PRIMARY KEY,
    device_id INTEGER REFERENCES devices(id) ON DELETE SET NULL,
    event_type VARCHAR(50) NOT NULL, -- 如: motion_detected, door_opened, smoke_detected等
    event_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    severity VARCHAR(20), -- low, medium, high, critical
    description TEXT,
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    image_url TEXT
);

-- 用户反馈表
CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    submission_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    feedback_type VARCHAR(50), -- bug, feature_request, complaint, compliment
    subject VARCHAR(100),
    message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'open', -- open, in_progress, resolved, closed
    assigned_to INTEGER REFERENCES users(id) ON DELETE SET NULL,
    priority VARCHAR(20) DEFAULT 'normal', -- low, normal, high, urgent
    response TEXT,
    response_time TIMESTAMP
);

-- 创建索引以提高查询性能
CREATE INDEX idx_devices_room ON devices(room_id);
CREATE INDEX idx_devices_type ON devices(device_type);
CREATE INDEX idx_usage_device ON device_usage(device_id);
CREATE INDEX idx_usage_time ON device_usage(start_time);
CREATE INDEX idx_security_events_time ON security_events(event_time);
CREATE INDEX idx_security_events_type ON security_events(event_type);
CREATE INDEX idx_feedback_user ON feedback(user_id);
CREATE INDEX idx_feedback_status ON feedback(status);


---------------------
-- example generate
---------------------
-- 插入用户数据
INSERT INTO users (username, password_hash, email, phone, full_name, created_at, last_login, is_active, is_admin)
VALUES
('john_doe', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGgaYlK', 'john.doe@example.com', '+8613812345678', 'John Doe', '2024-01-15 09:30:00', '2025-06-28 18:45:00', TRUE, FALSE),
('jane_smith', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGgaYlK', 'jane.smith@example.com', '+8613823456789', 'Jane Smith', '2024-02-20 14:15:00', '2025-06-29 08:30:00', TRUE, FALSE),
('admin', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGgaYlK', 'admin@smarthome.com', '+8613901234567', 'System Admin', '2024-01-01 00:00:00', '2025-06-29 10:00:00', TRUE, TRUE);

-- 插入用户住宅数据
INSERT INTO user_homes (user_id, address, area, city, country, postal_code, timezone)
VALUES
(1, '北京市朝阳区建国路88号', 120.5, '北京', '中国', '100025', 'Asia/Shanghai'),
(2, '上海市浦东新区张江高科技园区', 85.3, '上海', '中国', '201203', 'Asia/Shanghai'),
(3, '广州市天河区珠江新城', 200.0, '广州', '中国', '510623', 'Asia/Shanghai');

-- 插入房间数据
INSERT INTO rooms (home_id, name, room_type, floor, area)
VALUES
(1, '客厅', 'living room', 1, 35.2),
(1, '主卧', 'bedroom', 1, 25.0),
(1, '厨房', 'kitchen', 1, 15.8),
(2, '起居室', 'living room', 3, 28.5),
(2, '次卧', 'bedroom', 3, 18.0),
(3, '大客厅', 'living room', 15, 45.0),
(3, '主卧室', 'bedroom', 15, 30.0),
(3, '智能厨房', 'kitchen', 15, 20.0);

-- 插入设备数据
INSERT INTO devices (room_id, name, device_type, model, manufacturer, serial_number, ip_address, mac_address, firmware_version, is_online, last_seen, power_consumption, installation_date, status)
VALUES
(1, '客厅主灯', 'light', 'Hue White A19', 'Philips', 'PH12345678', '192.168.1.101', '00:11:22:33:44:55', '1.45.2', TRUE, '2025-06-29 11:30:00', 9.5, '2024-03-15', 'active'),
(1, '客厅空调', 'thermostat', 'AC-5000', 'Haier', 'HA87654321', '192.168.1.102', '00:11:22:33:44:56', '2.1.0', TRUE, '2025-06-29 11:28:00', 1500, '2024-02-10', 'active'),
(1, '客厅摄像头', 'camera', 'Cam Pro 3', 'Xiaomi', 'XM11223344', '192.168.1.103', '00:11:22:33:44:57', '3.2.1', TRUE, '2025-06-29 11:25:00', 5.0, '2024-04-05', 'active'),
(2, '卧室灯', 'light', 'Hue White A19', 'Philips', 'PH12345679', '192.168.1.104', '00:11:22:33:44:58', '1.45.2', TRUE, '2025-06-29 11:20:00', 9.5, '2024-03-20', 'active'),
(2, '卧室智能插座', 'outlet', 'Smart Plug', 'TP-Link', 'TPL98765432', '192.168.1.105', '00:11:22:33:44:59', '1.3.5', TRUE, '2025-06-29 11:15:00', 2.0, '2024-05-01', 'active'),
(3, '厨房灯', 'light', 'Hue White A19', 'Philips', 'PH12345680', '192.168.1.106', '00:11:22:33:44:60', '1.45.2', FALSE, '2025-06-28 22:00:00', 9.5, '2024-03-25', 'active'),
(4, '客厅主灯', 'light', 'Hue White A19', 'Philips', 'PH12345681', '192.168.1.107', '00:11:22:33:44:61', '1.45.2', TRUE, '2025-06-29 11:10:00', 9.5, '2024-04-10', 'active'),
(5, '卧室空调', 'thermostat', 'AC-3000', 'Gree', 'GR11223345', '192.168.1.108', '00:11:22:33:44:62', '1.9.0', TRUE, '2025-06-29 11:05:00', 1200, '2024-05-15', 'active'),
(6, '客厅主灯', 'light', 'Hue White A19', 'Philips', 'PH12345682', '192.168.1.109', '00:11:22:33:44:63', '1.45.2', TRUE, '2025-06-29 11:00:00', 9.5, '2024-01-20', 'active'),
(7, '卧室智能窗帘', 'curtain', 'Curtain Pro', 'Aqara', 'AQ11223346', '192.168.1.110', '00:11:22:33:44:64', '2.5.1', TRUE, '2025-06-29 10:55:00', 15.0, '2024-06-01', 'active'),
(8, '厨房烟雾报警器', 'sensor', 'Smoke Alarm 2', 'Nest', 'NE11223347', '192.168.1.111', '00:11:22:33:44:65', '1.2.3', TRUE, '2025-06-29 10:50:00', 1.5, '2024-06-10', 'active');

-- 插入设备使用记录
INSERT INTO device_usage (device_id, start_time, end_time, energy_consumption, operation_mode, user_id)
VALUES
(1, '2025-06-28 18:00:00', '2025-06-28 23:30:00', 0.052, 'warm white', 1),
(1, '2025-06-29 07:30:00', '2025-06-29 08:15:00', 0.007, 'cool white', 1),
(2, '2025-06-28 19:00:00', '2025-06-28 22:00:00', 4.5, 'cooling', 1),
(2, '2025-06-29 08:00:00', '2025-06-29 08:30:00', 0.75, 'cooling', 1),
(4, '2025-06-28 22:00:00', '2025-06-29 07:00:00', 0.085, 'warm white', 1),
(5, '2025-06-28 20:00:00', '2025-06-28 23:00:00', 0.012, 'on', 2),
(7, '2025-06-28 18:30:00', '2025-06-28 23:45:00', 0.050, 'warm white', 2),
(9, '2025-06-28 19:30:00', '2025-06-29 00:30:00', 6.0, 'cooling', 3),
(10, '2025-06-29 07:00:00', '2025-06-29 07:15:00', 0.004, 'open', 3);

-- 插入安防事件
INSERT INTO security_events (device_id, event_type, event_time, severity, description, is_resolved, resolved_by, resolved_at, resolution_notes, image_url)
VALUES
(3, 'motion_detected', '2025-06-28 23:15:00', 'low', '客厅检测到运动', TRUE, 1, '2025-06-28 23:20:00', '确认是家庭成员活动', 'https://example.com/images/event123.jpg'),
(3, 'motion_detected', '2025-06-29 02:30:00', 'medium', '客厅检测到异常运动', FALSE, NULL, NULL, NULL, 'https://example.com/images/event124.jpg'),
(11, 'smoke_detected', '2025-06-29 08:45:00', 'high', '厨房检测到烟雾', TRUE, 3, '2025-06-29 08:50:00', '确认是烹饪产生的烟雾，非火灾', NULL),
(8, 'door_opened', '2025-06-29 09:00:00', 'low', '前门被打开', TRUE, 2, '2025-06-29 09:01:00', '快递员送货', NULL);

-- 插入用户反馈
INSERT INTO feedback (user_id, submission_time, feedback_type, subject, message, status, assigned_to, priority, response, response_time)
VALUES
(1, '2025-06-15 10:30:00', 'feature_request', '增加场景模式', '希望能增加"离家模式"，一键关闭所有设备', 'resolved', 3, 'normal', '功能已开发完成，将在下个版本发布', '2025-06-18 14:00:00'),
(2, '2025-06-20 15:45:00', 'bug', '空调控制不灵敏', '卧室空调有时无法通过APP控制', 'in_progress', 3, 'high', '我们正在调查此问题，初步判断是网络连接问题', '2025-06-21 09:30:00'),
(1, '2025-06-28 21:00:00', 'complaint', '摄像头误报', '客厅摄像头夜间频繁误报运动检测', 'open', NULL, 'normal', NULL, NULL),
(3, '2025-06-29 09:30:00', 'compliment', '系统很好用', '智能家居系统大大提高了生活便利性', 'closed', NULL, 'low', '感谢您的反馈，我们会继续努力', '2025-06-29 10:00:00');
