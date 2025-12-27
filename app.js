document.addEventListener('DOMContentLoaded', () => {
    const terminal = document.getElementById('terminal-content');

    function log(message, type = 'info') {
        const entry = document.createElement('div');
        entry.className = `log-entry log-${type}`;
        
        const timestamp = new Date().toLocaleTimeString();
        entry.innerHTML = `<span style="opacity:0.5">[${timestamp}]</span> ${message}`;
        
        terminal.appendChild(entry);
        terminal.scrollTop = terminal.scrollHeight;
    }

    log('System initialized. Scanning for vulnerable contracts...', 'system');
    setTimeout(() => log('Connected to local simulation environment.', 'system'), 500);
    setTimeout(() => log('WARNING: Malicious entities detected.', 'warn'), 1200);

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

    // Attach listeners
    document.querySelectorAll('.action-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const trapType = e.target.dataset.trap;
            if (traps[trapType]) {
                traps[trapType]();
            }
        });
    });
});
