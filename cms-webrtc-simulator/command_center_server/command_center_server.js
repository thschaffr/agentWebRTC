// This is the new, reliable Node.js Command Center Server.
const http = require('http');
const readline = require('readline');

let status = 'WAITING'; // The initial state

// Create the server
const server = http.createServer((req, res) => {
    // These headers prevent caching, so workers always get the latest status
    res.writeHead(200, { 
        'Content-Type': 'text/plain', 
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0'
    });
    res.end(status);
});

// Start listening on port 8080 on all network interfaces
server.listen(8080, '0.0.0.0', () => {
    console.log('--- WebRTC Load Test Command Center ---');
    console.log('Server is running on port 8080');
    console.log('Worker VMs should now be connecting and waiting...');
    console.log('\n>>> PRESS [ENTER] TO SEND THE "GO!" SIGNAL <<<');
});

// Create an interface to read from the command line
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

// Wait for the user to press Enter
rl.question('', () => {
    status = 'GO!';
    console.log('\n**********************');
    console.log('*** GO SIGNAL SENT! ***');
    console.log('**********************');
    console.log('All workers have been instructed to start the load test.');
    console.log('This server will continue running to serve the "GO" signal.');
    console.log('Press CTRL+C to stop the command center.');
    rl.close();
});
