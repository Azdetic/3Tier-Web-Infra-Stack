CREATE DATABASE IF NOT EXISTS campus_info_db;
USE campus_info_db;

-- Create server inventory table
CREATE TABLE IF NOT EXISTS server_inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    server_name VARCHAR(100) NOT NULL,
    ip_address VARCHAR(15) NOT NULL,
    building_location VARCHAR(100) NOT NULL,
    managing_department VARCHAR(100) NOT NULL,
    primary_function TEXT NOT NULL,
    status ENUM('ONLINE', 'MAINTENANCE', 'OFFLINE') DEFAULT 'ONLINE',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Seed initial dummy data
INSERT INTO server_inventory (server_name, ip_address, building_location, managing_department, primary_function, status) VALUES
('SRV-ACADEMIC-01', '10.10.1.5', 'Rectorate Building 3rd Floor', 'Information Systems Directorate', 'Academic Information & Student Registration System', 'ONLINE'),
('DB-STUDENT-MAIN', '10.10.2.10', 'Main Data Center', 'Faculty of Information Systems', 'Student Master Database', 'ONLINE'),
('SRV-ELEARNING-01', '10.10.5.22', 'Block 17 Server Room', 'Learning Technology Center', 'Campus E-Learning Platform Host', 'ONLINE'),
('SRV-LIBRARY', '10.10.6.15', 'Information Resource Centre', 'Library Department', 'Digital Book Lending & Catalog System', 'ONLINE'),
('SRV-BACKUP-NODE', '10.10.9.99', 'Business Administration Building 1st Floor', 'IT Infrastructure Directorate', 'Weekly Backup Node', 'MAINTENANCE');
