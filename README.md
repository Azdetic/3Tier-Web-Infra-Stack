# Campus Server Inventory & Web Observability Stack

Hey everyone 
If you are a student too you definitely know the struggle when campus websites crash during course registration or exam results day
I was curious how real IT admins handle this and keep the servers alive
So I built this project to learn how to setup and monitor a production-ready web infrastructure 


## The Problem & How I Solved It

**The Problem:**
Usually beginners put everything (web frontend and database) in one single machine
If one thing breaks the whole campus web goes down completely
Also putting your database in public is a massive security risk

**My Solution:**
I used **Docker Compose** to split the system into isolated microservices:
* **The Storefront (Apache2):** Handles visitor traffic on port `8080`
* **The Vault (MySQL Database):** Hidden deeply inside a private virtual network to keep campus asset data safe
* **The Watchman (Prometheus + Blackbox Exporter):** Constantly pings the web server to check if it is responding
* **The Command Center (Grafana):** A dashboard that turns raw data into clear ONLINE or OFFLINE status


## System Architecture & Data Flow

Here is how all the pieces fit together inside the host machine

```text
┌────────────────────────────────────────────────────────────────────────┐
│                          LOCAL HOST MACHINE                            │
│                       (Docker Desktop / WSL2)                          │
│                                                                        │
│   Student / Admin Access                                               │
│   http://localhost:8080                                                │
│        │                                                               │
│   ┌────▼───────────────────────────────────────────────────────────┐   │
│   │             ISOLATED DOCKER BRIDGE (`web_network`)             │   │
│   │                                                                │   │
│   │  ┌────────────────────────┐     ┌──────────────────────────┐   │   │
│   │  │   Apache2 Web Server   │     │   MySQL Database Engine  │   │   │
│   │  │   (Container: apache_web)│   │   (Container: mysql_db)  │   │   │
│   │  │                        │     │                          │   │   │
│   │  │   Port: 8080 -> 80     │     │   Port: 3306 (Internal)  │   │   │
│   │  │   Serves the Frontend  │     │   Holds Campus Assets    │   │   │
│   │  └───────────▲────────────┘     └─────────────▲────────────┘   │   │
│   │              │                                │                │   │
│   │         HTTP Pings                       SQL Queries           │   │
│   │              │                                │                │   │
│   │  ┌───────────┴────────────┐                   │                │   │
│   │  │    Blackbox Exporter   │                   │                │   │
│   │  └───────────▲────────────┘                   │                │   │
│   │              │ Metrics Scrape                 │                │   │
│   │  ┌───────────┴────────────┐                   │                │   │
│   │  │       Prometheus       │───────────────────┘                │   │
│   │  └───────────▲────────────┘                                    │   │
│   │              │ PromQL                                          │   │
│   │  ┌───────────┴────────────┐                                    │   │
│   │  │    Grafana Dashboard   │ ──▶ Opens at http://localhost:3000 │   │
│   │  └────────────────────────┘                                    │   │
│   └────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────┘
```


## My Troubleshooting Journey

Building this was fun but challenging
I ran into a couple of issues that forced me to learn how real SysAdmins work

* **The Database Security Trap:** At first I used basic passwords like `securepassword123` and a user named `campus_admin`
I realized that is bad for real-world security so I upgraded the infrastructure to use strict enterprise-style credentials like `infra_db_admin`
* **The Web Monitoring Dilemma:** Monitoring a live web application is different from monitoring a router
I had to learn how to configure the **Blackbox Exporter** to send internal HTTP requests and map those outputs into Grafana so it shows a simple text status


## Project Directory Setup

I keep my code clean and structured like this

```text
web-infra-stack/
│
├── docker-compose.yml          # The blueprint orchestrating all 5 containers
├── init.sql                    # Auto-seeding script for our campus database
├── html/                       
│   └── index.html              # Simple frontend landing page
└── prometheus/
    └── prometheus.yml          # Scrape targets and Blackbox routing rules
```


## Testing the Stack (Proof of Concept)

I tested this to make sure the automation works perfectly without manual intervention

### 1 Database Automation Test

When the MySQL container boots up it automatically reads `init.sql` to build the database. Here is the exact schema running under the hood:

```sql
CREATE DATABASE IF NOT EXISTS campus_info_db;
USE campus_info_db;

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
```

I ran a terminal check inside the live container to verify the seeding process:

```bash
docker exec -it mysql_db mysql -u infra_db_admin -p"SysP@ssW0rd!2026" campus_info_db -e "SELECT * FROM server_inventory;"
```

**The Result:** The terminal perfectly printed a structured asset management table containing my campus server mock data

### 2 Live Outage Simulation Test

I wanted to test if my Grafana dashboard is smart enough to flag an emergency
I intentionally killed the web server container using the terminal:

```bash
docker compose stop web
```

**The Reaction:**
Within seconds the Blackbox exporter noticed the failure and Prometheus caught it
My Grafana dashboard dynamically flipped its massive green ONLINE banner into a bright red OFFLINE warning just like this:

![Web Online Dashboard](./Web%20Online.png)

![Web Offline Dashboard](./Web%20Offline.png)

Running `docker compose start web` brought everything back to normal instantly
It flows like water and shows exactly how the monitoring reacts to a real problem


## Conclusion

This project taught me that managing an IT infrastructure is not just about writing code
It is about automation and building reliable foundations
Being able to spin up a web server and a fully functional monitoring pipeline with just one command `docker compose up -d` feels like absolute magic
Thanks for checking out my repository
