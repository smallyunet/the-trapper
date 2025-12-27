document.addEventListener('DOMContentLoaded', () => {
    // --- Matrix Rain Effect ---
    const canvas = document.getElementById('matrix');
    const ctx = canvas.getContext('2d');

    // Make canvas full screen
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    const chars = '01';
    const fontSize = 14;
    const columns = canvas.width / fontSize;
    const drops = [];

    // Initialize drops
    for (let x = 0; x < columns; x++) {
        drops[x] = 1;
    }

    function drawMatrix() {
        ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        ctx.fillStyle = '#0F0';
        ctx.font = fontSize + 'px monospace';

        for (let i = 0; i < drops.length; i++) {
            const text = chars.charAt(Math.floor(Math.random() * chars.length));
            ctx.fillText(text, i * fontSize, drops[i] * fontSize);

            if (drops[i] * fontSize > canvas.height && Math.random() > 0.975) {
                drops[i] = 0;
            }
            drops[i]++;
        }
    }
    // Loop
    setInterval(drawMatrix, 50);

    // Resize handler
    window.addEventListener('resize', () => {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    });


    // --- Terminal & Trap Logic ---
    const terminal = document.getElementById('terminal-content');
    const cliInput = document.getElementById('cli-input');
    const terminalContainer = document.getElementById('terminal');

    function log(message, type = 'info') {
        const entry = document.createElement('div');
        entry.className = `log-entry log-${type}`;

        const timestamp = new Date().toLocaleTimeString();
        entry.innerHTML = `<span style="opacity:0.5">[${timestamp}]</span> ${message}`;

        terminal.appendChild(entry);
        terminalContainer.scrollTop = terminalContainer.scrollHeight;
    }

    // Trap Handlers
    const traps = {
        'storage-ghost': () => {
            log('Initiating attack on StorageGhost...', 'info');
            setTimeout(() => log('Sending delegatecall to overwrite owner...', 'info'), 800);
            setTimeout(() => {
                log('CRITICAL: Transaction reverted! Gas Limit Exceeded.', 'error');
                log('Analysis: wrote to hidden trapSlot instead of owner.', 'system');
            }, 2000);
        },
        'antimev': () => {
            log('Spotting arbitrage opportunity on AntiMEV...', 'info');
            setTimeout(() => log('Simulating transaction...', 'info'), 600);
            setTimeout(() => log('Simulation result: SUCCESS. Profit: 10 ETH', 'success'), 1200);
            setTimeout(() => {
                log('Broadcasting transaction to mempool...', 'info');
                log('Transaction included in block.', 'info');
                log('ERROR: Transaction failed silently. Gas consumed.', 'error');
                log('Analysis: Contract detected real execution vs simulation.', 'system');
            }, 2500);
        },
        'reentrancy': () => {
            log('Target found: ReentrancyBait. Vulnerable withdrawal pattern.', 'info');
            setTimeout(() => log('Deploying malicious contract...', 'info'), 800);
            setTimeout(() => log('Calling withdraw()...', 'info'), 1500);
            setTimeout(() => log('Re-entering withdraw()...', 'warn'), 2000);
            setTimeout(() => {
                log('Re-entrancy successful (internal state)...', 'warn');
                log('Finalizing transaction...', 'info');
                log('FATAL: Execution trapped. Hidden guard detected.', 'error');
            }, 3000);
        },
        'flashloan': () => {
            log('Requesting Flash Loan (1,000,000 USDC)...', 'info');
            setTimeout(() => log('Loan received. executing strategy...', 'info'), 1000);
            setTimeout(() => log('Attempting to bypass repayment check...', 'warn'), 2000);
            setTimeout(() => {
                log('ALERT: Invalid opcode triggered.', 'error');
                log('All gas burned. Repayment verification failed.', 'system');
            }, 3000);
        },
        'honeypot': () => {
            log('Buying 10,000 GHOST tokens...', 'info');
            setTimeout(() => log('Swap Successful! Received 10,000 GHOST.', 'success'), 1000);
            setTimeout(() => log('Attempting to sell GHOST for profit...', 'info'), 2500);
            setTimeout(() => {
                log('ERROR: Transfer failed.', 'error');
                log('Simulation: Cannot sell. Token is a Honeypot.', 'system');
            }, 3500);
        }
    };

    // Button Listeners
    document.querySelectorAll('.action-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const trapType = e.target.dataset.trap;
            if (traps[trapType]) {
                traps[trapType]();
            }
        });
    });

    // --- CLI Logic ---
    const commands = {
        'help': () => {
            log('Available commands:', 'system');
            log('  help     - Show this help message', 'info');
            log('  scan     - Scan for vulnerable contracts', 'info');
            log('  clear    - Clear terminal info', 'info');
            log('  exploit  - List available exploit targets', 'info');
            log('  whoami   - Display current user', 'info');
        },
        'clear': () => {
            terminal.innerHTML = '<div class="log-entry log-system">System cleared.</div>';
        },
        'scan': () => {
            log('Scanning network.........', 'info');
            setTimeout(() => log('Found 5 vulnerable candidates.', 'success'), 1000);
        },
        'exploit': () => {
            log('Targets identified:', 'system');
            log('  1. StorageGhost (Delegation)', 'warn');
            log('  2. AntiMEV (Arbitrage)', 'warn');
            log('  3. ReentrancyBait (Withdrawal)', 'warn');
            log('  4. FlashLoanTrap (Lending)', 'warn');
            log('  5. HoneypotToken (ERC20)', 'warn');
            log("Use UI buttons to execute simulation.", 'info'); // Or implement args parsing later
        },
        'whoami': () => {
            log('root', 'success');
        }
    };

    cliInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            const input = cliInput.value.trim();
            if (input) {
                // Echo command
                log(`root@trapper:~# ${input}`, 'info');

                // Execute
                const [cmd, ...args] = input.split(' ');
                if (commands[cmd]) {
                    commands[cmd](args);
                } else {
                    log(`Command not found: ${cmd}`, 'error');
                }
            }
            cliInput.value = '';
        }
    });

    // Auto-focus CLI
    terminalContainer.addEventListener('click', () => {
        cliInput.focus();
    });
});
