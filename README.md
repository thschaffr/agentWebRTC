<img width="180" height="180" alt="logo" src="https://github.com/user-attachments/assets/598d51e1-5f31-4cdf-a60f-86483e23e341" />

# CMS WebRTC Simulator

This project provides a powerful suite of tools to simulate a high volume of simultaneous WebRTC guest joins to a Cisco Meeting Server (CMS). It is designed to be a self-contained, "one-click" solution for Windows nodes, allowing you to easily generate significant load on your CMS infrastructure to test performance and stability.

The simulator launches multiple instances of a headless Chrome browser, each configured to bypass bot detection and join a specified meeting as a guest.

## Quick Start: Running a Local Test

This guide will get you running a load test from a single Windows machine in minutes.

### Step 1: Configure Your Test

Before launching, you need to tell the bots where to go and how many to launch.

1.  Navigate to the `loadrunner` folder.
2.  Open the `final_loadtest.js` file in a text editor.
3.  Modify the variables in the **`Configuration`** section at the top of the file:

```javascript
// --- Configuration ---
const totalBots = 100; // The total number of bots you want the test to run over its lifetime.
const concurrencyLimit = 15; // The maximum number of bots running at the exact same time.
// ---------------------

const meetingBaseUrl = "https://10.49.210.179/en-US/meeting/123"; // IMPORTANT: Change this to your CMS meeting URL.
const joinButtonSelector = "._3vkSKa"; // The CSS selector for the "Join" button on your CMS page.
```

*   **`totalBots`**: The total number of sessions the script will run before it finishes.
*   **`concurrencyLimit`**: The most important performance setting. This is the number of bots that will be active *simultaneously*. Set this to the maximum your Windows machine can handle.
*   **`meetingBaseUrl`**: The target URL for your CMS meeting. The script will automatically append the bot's name and other parameters to this URL.
*   **`joinButtonSelector`**: The unique CSS selector for the "Join" button on your CMS web page. You can find this by right-clicking the button in your browser, selecting "Inspect," right-clicking the highlighted HTML, and choosing "Copy > Copy selector."

### Step 2: Launch the Test

Once configured, running the test is simple:

1.  Navigate to the `loadrunner` folder.
2.  Double-click the **`run-local.bat`** file.

That's it! A command prompt window will open.
*   **On the first run**, it will automatically download a portable version of Node.js and install all the necessary dependencies. This may take a few minutes.
*   **On all subsequent runs**, it will detect that the setup is complete and will immediately start the load test.

You will see status messages in the window as bots are launched and successfully join the meeting lobby. To stop the test at any time, press `CTRL+C` in the command prompt window.

---

## Scaling the Load Test (Multi-VM Simulation)

To simulate a truly massive number of users (e.g., 500+), you need to distribute the load across multiple Windows VMs. This project uses a simple and effective "Command Center & Worker" model to synchronize the launch across all machines.

### How It Works

1.  One VM is designated as the **Command Center**. It runs a simple web server that waits for you to give the "GO!" signal.
2.  All other VMs are **Workers**. They run a script that continuously checks the Command Center's web server.
3.  When you press a key on the Command Center, the web server's status changes. All workers see the change and launch their load tests simultaneously.

### The Launch Sequence: A 3-VM Example

Let's say you have 3 Windows VMs: VM1 (Command Center), VM2 (Worker), and VM3 (Worker).

#### 1. Set up the Command Center (VM1)
*   Copy the `command_center_server` folder to this VM.
*   Find this VM's local IP address by opening `cmd` and typing `ipconfig`. (e.g., `192.168.1.101`).
*   Double-click **`run_command_center.bat`**. The first time, it will download Node.js. It will then start the server and display: `>>> PRESS [ENTER] TO SEND THE "GO!" SIGNAL <<<`.

#### 2. Set up the Workers (VM2 & VM3)
*   On each worker VM, copy the `loadrunner` folder.
*   Run the `run-local.bat` script **once** on each worker to ensure Node.js and all dependencies are installed.
*   Open the **`worker.bat`** file in a text editor.
*   Change the `COMMAND_CENTER_IP` variable to the IP address of your Command Center VM (e.g., `SET COMMAND_CENTER_IP=192.168.1.101`). Save the file.
*   Double-click **`worker.bat`** on both VM2 and VM3. They will now open a window and display: `[INFO] Waiting for the "GO!" signal...`.

#### 3. Launch the Synchronized Test
*   Go back to the Command Center VM (VM1).
*   Press **Enter** in the command prompt window.

All worker VMs will instantly detect the signal and launch their `final_loadtest.js` scripts in a new window, creating a massive, simultaneous wave of traffic.

---

## Technical Details: How It Works

### The Core Engine (`final_loadtest.js`)
This is the heart of the simulator. It uses the powerful **Puppeteer** library to control headless instances of the Chromium browser. Key features include:
*   **Headless Operation**: Browsers are run in the background without a visible UI, allowing for massive resource savings and high scalability.
*   **Bot Detection Evasion**: It uses the `puppeteer-extra-plugin-stealth` library. This automatically applies numerous patches to the headless browser to make it appear like a real, human-operated browser, which is critical for bypassing modern server security.
*   **Worker Pool**: The script uses a concurrency-limited worker pool. This ensures that it never launches more bots than your machine can handle (`concurrencyLimit`), preventing crashes and providing a stable, sustained load on the target server.
*   **Optimized Joins**: The meeting URL is constructed with `&videoDisabled=true&audioMuted` parameters to reduce the load of each connection.

### Dependencies (`package.json`)
This file is the "shopping list" for the project. When `run-local.bat` runs the `npm install` command, `npm` reads this file to know which libraries need to be downloaded, such as `puppeteer` and `puppeteer-extra`.

### The Launchers
*   **`run-local.bat`**: A self-contained, all-in-one script. It downloads its own portable copy of Node.js and handles dependency installation, making the project runnable on any Windows machine with zero pre-configuration.
*   **`worker.bat`**: A specialized version of the launcher. Instead of running the test immediately, it enters a polling loop, repeatedly checking the Command Center's web server until it receives the "GO!" signal.

### The Command Center (`command_center_server.js`)
This is a minimalist Node.js web server. It serves a single page with the text "WAITING" until you press Enter in its console, at which point it begins serving "GO!" to all connected workers.

## Performance & Tuning
The primary setting for tuning performance is the `concurrencyLimit` variable inside `final_loadtest.js`.

This tool has been successfully tested to run with a **`concurrencyLimit` of 70** on a Windows VM with 20 CPU cores, generating a stable and significant load on the target CMS. Your mileage may vary depending on the resources allocated to your VM. It is recommended to start with a lower limit (e.g., 15) and gradually increase it while monitoring your VM's CPU and Memory usage in the Task Manager.
