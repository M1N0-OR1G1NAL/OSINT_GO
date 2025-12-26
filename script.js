    // === INIT ===
document.addEventListener("DOMContentLoaded", () => {
    initClock();
    initNavigation();
    initApps();
    initSettings();
    initMatrix();
    initRecon();
    initSecurity();
    logEvent("System boot complete.");
});

    // === CLOCK ===
function initClock() {
    const clockEl = document.getElementById("clock");
    if (!clockEl) return;
    
    const update = () => {
        const now = new Date();
        const date = now.toLocaleDateString("cs-CZ");
        const time = now.toLocaleTimeString("cs-CZ", { hour12: false });
        clockEl.textContent = `${date} ${time}`;
    };
    
    update();
    setInterval(update, 1000);
}

    // === NAVIGATION BETWEEN SCREENS ===
function initNavigation() {
    const navLinks = document.querySelectorAll(".nav-link");
    const screens = document.querySelectorAll(".screen");
    
    navLinks.forEach(link => {
        link.addEventListener("click", () => {
            const target = link.dataset.screen;
            
            navLinks.forEach(l => l.classList.remove("active"));
            link.classList.add("active");
            
            screens.forEach(screen => {
                if (screen.id === `screen-${target}`) {
                    screen.classList.add("active");
                } else {
                    screen.classList.remove("active");
                }
            });
            
            logEvent(`Switched to screen: ${target}`);
        });
    });
    
        // podpora tlačítek na Dashboardu s data-screen-jump
    const jumpButtons = document.querySelectorAll("[data-screen-jump]");
    jumpButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            const target = btn.dataset.screenJump;
            const navBtn = document.querySelector(`.nav-link[data-screen="${target}"]`);
            if (navBtn) navBtn.click();
        });
    });
}

    // === APP WINDOWS / MINI APPS ===
function initApps() {
    const overlay = document.getElementById("app-overlay");
    const windows = document.querySelectorAll(".app-window");
    const appCards = document.querySelectorAll(".app-card");
    const quickButtons = document.querySelectorAll("[data-open-app]");
    const closeButtons = document.querySelectorAll(".app-window-close");
    
    const openApp = (appName) => {
        if (!overlay) return;
        overlay.classList.remove("hidden");
        
        windows.forEach(win => {
            if (win.dataset.appWindow === appName) {
                win.classList.add("active");
            } else {
                win.classList.remove("active");
            }
        });
        
        logEvent(`Opened app: ${appName}`);
    };
    
    const closeOverlay = () => {
        overlay.classList.add("hidden");
        windows.forEach(win => win.classList.remove("active"));
    };
    
    appCards.forEach(card => {
        card.addEventListener("click", () => {
            const appName = card.dataset.app;
            openApp(appName);
        });
    });
    
    quickButtons.forEach(btn => {
        btn.addEventListener("click", () => {
            const appName = btn.dataset.openApp;
            openApp(appName);
        });
    });
    
    closeButtons.forEach(btn => {
        btn.addEventListener("click", closeOverlay);
    });
    
    overlay.addEventListener("click", (e) => {
        if (e.target === overlay) {
            closeOverlay();
        }
    });
    
    initNotesApp();
    initTodoApp();
    initTerminalApp();
}

    // === NOTES APP ===
function initNotesApp() {
    const textarea = document.getElementById("notes-area");
    if (!textarea) return;
    
    const KEY = "app_notes_v1";
    textarea.value = localStorage.getItem(KEY) || "";
    
    textarea.addEventListener("input", () => {
        localStorage.setItem(KEY, textarea.value);
    });
}

    // === TODO APP ===
function initTodoApp() {
    const input = document.getElementById("todo-input");
    const addBtn = document.getElementById("todo-add");
    const list = document.getElementById("todo-list");
    if (!input || !addBtn || !list) return;
    
    const KEY = "app_todo_v1";
    let tasks = [];
    
    const loadTasks = () => {
        try {
            const stored = JSON.parse(localStorage.getItem(KEY));
            if (Array.isArray(stored)) tasks = stored;
        } catch {
            tasks = [];
        }
    };
    
    const saveTasks = () => {
        localStorage.setItem(KEY, JSON.stringify(tasks));
    };
    
    const renderTasks = () => {
        list.innerHTML = "";
        tasks.forEach((task, index) => {
            const li = document.createElement("li");
            li.className = "todo-item";
            
            const label = document.createElement("label");
            label.className = "todo-label";
            
            const checkbox = document.createElement("input");
            checkbox.type = "checkbox";
            checkbox.checked = task.done;
            checkbox.addEventListener("change", () => {
                tasks[index].done = checkbox.checked;
                saveTasks();
                renderTasks();
            });
            
            const span = document.createElement("span");
            span.textContent = task.text;
            span.className = "todo-text";
            if (task.done) span.classList.add("completed");
            
            label.appendChild(checkbox);
            label.appendChild(span);
            
            const removeBtn = document.createElement("button");
            removeBtn.className = "todo-remove";
            removeBtn.textContent = "X";
            removeBtn.addEventListener("click", () => {
                tasks.splice(index, 1);
                saveTasks();
                renderTasks();
            });
            
            li.appendChild(label);
            li.appendChild(removeBtn);
            list.appendChild(li);
        });
    };
    
    const addTask = () => {
        const text = input.value.trim();
        if (!text) return;
        tasks.push({ text, done: false });
        input.value = "";
        saveTasks();
        renderTasks();
        logEvent(`Added task: ${text}`);
    };
    
    addBtn.addEventListener("click", addTask);
    input.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
            e.preventDefault();
            addTask();
        }
    });
    
    loadTasks();
    renderTasks();
}

    // === TERMINAL APP (SIMULATED) ===
function initTerminalApp() {
    const output = document.getElementById("terminal-output");
    const form = document.getElementById("terminal-form");
    const input = document.getElementById("terminal-input");
    if (!output || !form || !input) return;
    
    const printLine = (text, type = "normal") => {
        const line = document.createElement("div");
        line.className = `terminal-line ${type}`;
        line.innerHTML = text;
        output.appendChild(line);
        output.scrollTop = output.scrollHeight;
    };
    
    const commands = {
        help() {
            printLine("Available commands:", "system");
            printLine("- <span class='cmd'>help</span>  : zobrazí tuto nápovědu");
            printLine("- <span class='cmd'>clear</span> : vyčistí obrazovku");
            printLine("- <span class='cmd'>time</span>  : zobrazí aktuální čas");
            printLine("- <span class='cmd'>echo &lt;text&gt;</span> : vypíše text");
        },
        clear() {
            output.innerHTML = "";
        },
        time() {
            const now = new Date();
            printLine(`Time: ${now.toLocaleString("cs-CZ")}`, "system");
        },
        echo(args) {
            const text = args.join(" ");
            printLine(text || "&nbsp;");
        }
    };
    
    printLine("Simulated shell ready. Type <span class='cmd'>help</span> for commands.", "system");
    
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const value = input.value.trim();
        if (!value) return;
        
        printLine(`agent@local:~$ ${value}`);
        handleCommand(value);
        input.value = "";
    });
    
    const handleCommand = (line) => {
        const parts = line.split(/\s+/);
        const cmd = parts[0].toLowerCase();
        const args = parts.slice(1);
        
        if (commands[cmd]) {
            commands[cmd](args);
        } else {
            printLine(`Command not found: ${cmd}`, "error");
        }
    };
}

    // === SETTINGS ===
function initSettings() {
    const themeRadios = document.querySelectorAll("input[name='theme']");
    const glowCheckbox = document.getElementById("setting-glow");
    const animCheckbox = document.getElementById("setting-animations");
    
        // Theme
    themeRadios.forEach(radio => {
        radio.addEventListener("change", () => {
            document.body.classList.remove("theme-amber", "theme-ice");
            
            if (radio.checked) {
                if (radio.value === "amber") {
                    document.body.classList.add("theme-amber");
                } else if (radio.value === "ice") {
                    document.body.classList.add("theme-ice");
                }
            }
            logEvent(`Theme changed: ${radio.value}`);
        });
    });
    
        // Glow
    if (glowCheckbox) {
        glowCheckbox.addEventListener("change", () => {
            if (glowCheckbox.checked) {
                document.body.classList.remove("no-glow");
            } else {
                document.body.classList.add("no-glow");
            }
            logEvent(`Glow ${glowCheckbox.checked ? "enabled" : "disabled"}`);
        });
    }
    
        // Animations
    if (animCheckbox) {
        animCheckbox.addEventListener("change", () => {
            if (animCheckbox.checked) {
                document.body.classList.remove("no-animations");
            } else {
                document.body.classList.add("no-animations");
            }
            logEvent(`Animations ${animCheckbox.checked ? "enabled" : "disabled"}`);
        });
    }
}

    // === EVENT LOG ===
function logEvent(message) {
    const log = document.getElementById("event-log");
    if (!log) return;
    
    const time = new Date().toLocaleTimeString("cs-CZ", { hour12: false });
    const line = document.createElement("div");
    line.className = "event-log-line";
    line.textContent = `[${time}] ${message}`;
    log.appendChild(line);
    log.scrollTop = log.scrollHeight;
}

    // === MATRIX BACKGROUND ===
function initMatrix() {
    const canvas = document.getElementById("matrixCanvas");
    if (!canvas) return;
    
    const ctx = canvas.getContext("2d");
    let width = canvas.width = window.innerWidth;
    let height = canvas.height = window.innerHeight;
    
    const characters = "01ABCDEFGHIJKLMNOPQRSTUVWXYZ#$%&*@";
    const fontSize = 16;
    let columns = Math.floor(width / fontSize);
    let drops = Array.from({ length: columns }, () => Math.random() * height / fontSize);
    
    const draw = () => {
        ctx.fillStyle = "rgba(0, 0, 0, 0.05)";
        ctx.fillRect(0, 0, width, height);
        
        ctx.fillStyle = "#3cff78";
        ctx.font = `${fontSize}px monospace`;
        
        for (let i = 0; i < drops.length; i++) {
            const text = characters.charAt(Math.floor(Math.random() * characters.length));
            const x = i * fontSize;
            const y = drops[i] * fontSize;
            
            ctx.fillText(text, x, y);
            
            if (y > height && Math.random() > 0.975) {
                drops[i] = 0;
            }
            
            drops[i]++;
        }
        
        requestAnimationFrame(draw);
    };
    
    draw();
    
    window.addEventListener("resize", () => {
        width = canvas.width = window.innerWidth;
        height = canvas.height = window.innerHeight;
        columns = Math.floor(width / fontSize);
        drops = Array.from({ length: columns }, () => Math.random() * height / fontSize);
    });
}

    // === RECON / OSINT PANEL (přepis AppleScriptu) ===
    //
    // Používej jen pro legální OSINT (vlastní infra, souhlas, bug bounty).
    //
function initRecon() {
    const form = document.getElementById("recon-form");
    const resultsEl = document.getElementById("recon-results");
    const statusEl = document.getElementById("recon-status");
    const openTabsBtn = document.getElementById("recon-open-tabs");
    const saveLogCheckbox = document.getElementById("recon-save-log");
    
    if (!form || !resultsEl || !statusEl || !openTabsBtn) return;
    
    const inputs = {
        "Doména": document.getElementById("recon-domain"),
        "IP adresa": document.getElementById("recon-ip"),
        "Uživatelské jméno": document.getElementById("recon-username"),
        "E-mail": document.getElementById("recon-email"),
        "Telefonní číslo": document.getElementById("recon-phone"),
        "IČO": document.getElementById("recon-ico"),
        "Adresa": document.getElementById("recon-address"),
        "UVID / jiné ID": document.getElementById("recon-uvid")
    };
    
    let lastUrlList = [];
    let lastEnrichmentMatches = []; // store enrichment results for open-button
    
    const setStatus = (text, isError = false) => {
        statusEl.className = "recon-status";
        if (isError) statusEl.classList.add("recon-error");
        statusEl.textContent = text;
    };
    
    const renderResults = (byType) => {
        resultsEl.innerHTML = "";
        const types = Object.keys(byType);
        if (!types.length) {
            resultsEl.innerHTML = "<div class='recon-item'>Nebyly zadány žádné vstupy.</div>";
            return;
        }
        
        types.forEach(tLabel => {
            const urls = byType[tLabel];
            if (!urls || !urls.length) return;
            
            const heading = document.createElement("div");
            heading.className = "recon-group-title";
            heading.textContent = `> ${tLabel}`;
            resultsEl.appendChild(heading);
            
            urls.forEach(u => {
                const item = document.createElement("div");
                item.className = "recon-item";
                
                const urlDiv = document.createElement("div");
                urlDiv.className = "recon-item-url";
                
                const a = document.createElement("a");
                a.href = u;
                a.target = "_blank";
                a.rel = "noopener noreferrer";
                a.textContent = u;
                
                urlDiv.appendChild(a);
                item.appendChild(urlDiv);
                
                resultsEl.appendChild(item);
            });
        });
    };
    
    const saveExplorationLog = (usedInputs) => {
        if (!usedInputs.length) return;
        
        const now = new Date();
        const stamp = now.toISOString().replace("T", " ").substring(0, 19);
        const fileStamp = stamp.replace(/[: ]/g, "_");
        
        const lines = [];
        lines.push(`==== OSINT EXPLORATION ${stamp} ====`);
        usedInputs.forEach(({ typeLabel, value }) => {
            lines.push(`${typeLabel}: ${value}`);
        });
        lines.push(""); // prázdný řádek
        
        const text = "\n" + lines.join("\n") + "\n";
        const blob = new Blob([text], { type: "text/plain" });
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `OSINT_Exploration_${fileStamp}.log`;
        document.body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
    };
    
    form.addEventListener("submit", (e) => {
        e.preventDefault();
        
        const usedInputs = [];
        for (const [label, el] of Object.entries(inputs)) {
            const value = (el?.value || "").trim();
            if (value) {
                usedInputs.push({ typeLabel: label, value });
            }
        }
        
        if (!usedInputs.length) {
            setStatus("Nezadals žádnou hodnotu.");
            resultsEl.innerHTML = "";
            lastUrlList = [];
            lastEnrichmentMatches = [];
            return;
        }
        
        const byType = {};
        let urlList = [];
        
        usedInputs.forEach(entry => {
            const urls = buildUrlsForTypeJS(entry.typeLabel, entry.value);
            byType[entry.typeLabel] = urls;
            urlList = urlList.concat(urls);
        });
        
            // deduplikace
        const unique = Array.from(new Set(urlList));
        lastUrlList = unique;
        
        renderResults(byType);
        setStatus(`Hotovo. Vygenerováno ${unique.length} URL (viz výše).`);
        
        logEvent(
                 "Recon inputs: " +
                 usedInputs
                 .map(e => `${e.typeLabel}=${e.value}`)
                 .join(", ") +
                 ` (URLs: ${unique.length})`
                 );
        
            // run enrichment heuristics and render
        autoEnrich(usedInputs, byType);
        
        if (saveLogCheckbox && saveLogCheckbox.checked) {
            saveExplorationLog(usedInputs);
        }
    });
    
    openTabsBtn.addEventListener("click", () => {
        if (!lastUrlList.length) {
            setStatus("Nejsou žádné vygenerované URL – nejdřív odešli formulář.");
            return;
        }
        
        setStatus(`Zkouším otevřít ${lastUrlList.length} tabů (prohlížeč může některé blokovat).`);
        
            // prohlížeč může kvůli popup blockingu část z toho zahodit
        lastUrlList.forEach(u => {
            window.open(u, "_blank");
        });
        
            // open enrichment matches if auto-open enabled
        const autoOpenCheckbox = document.getElementById('recon-auto-open-enrich');
        if (autoOpenCheckbox && autoOpenCheckbox.checked && lastEnrichmentMatches.length) {
            const toOpen = [];
            lastEnrichmentMatches.forEach(m => {
                if (m.urls && m.urls.length) {
                    m.urls.slice(0, 2).forEach(u => toOpen.push(u));
                }
            });
            toOpen.slice(0, 8).forEach(u => window.open(u, '_blank'));
        }
        
        logEvent(`Recon: attempt to open ${lastUrlList.length} tabs.`);
    });
    
        // expose lastEnrichmentMatches for debugging
    window.__lastEnrichmentMatches = () => lastEnrichmentMatches;
    
        // helper: renderProbableMatches - central renderer used by autoEnrich
    function renderProbableMatches(containerEl, matches) {
            // store for open-button
        lastEnrichmentMatches = matches || [];
        if (!containerEl) return;
        const wrapper = document.createElement("div");
        wrapper.className = "recon-probable-matches";
        
        const title = document.createElement("div");
        title.className = "recon-group-title";
        title.textContent = "> Pravděpodobné shody / enrichment";
        wrapper.appendChild(title);
        
        if (!matches || !matches.length) {
            const none = document.createElement("div");
            none.className = "recon-item";
            none.textContent = "Nebyla nalezena žádná automatická shoda (heuristicky).";
            wrapper.appendChild(none);
            containerEl.appendChild(wrapper);
            return;
        }
        
        matches.forEach(m => {
            const item = document.createElement("div");
            item.className = "recon-item";
            
            const header = document.createElement("div");
            header.style.marginBottom = "6px";
            header.innerHTML = `<strong>${m.label}</strong> <span style="opacity:0.85">(${m.kind})</span>`;
            item.appendChild(header);
            
            if (m.urls && m.urls.length) {
                const list = document.createElement("div");
                list.className = "recon-item-url";
                m.urls.forEach(u => {
                    const a = document.createElement("a");
                    a.href = u;
                    a.target = "_blank";
                    a.rel = "noopener noreferrer";
                    a.textContent = u;
                    list.appendChild(a);
                    list.appendChild(document.createElement("br"));
                });
                item.appendChild(list);
            } else if (m.value) {
                const vdiv = document.createElement("div");
                vdiv.textContent = m.value;
                item.appendChild(vdiv);
            }
            
            wrapper.appendChild(item);
        });
        
        containerEl.appendChild(wrapper);
    }
    
        // add auto-open enrichment checkbox control if missing
    if (!document.getElementById('recon-auto-open-enrich')) {
        const control = document.createElement('label');
        control.style.fontSize = '0.9rem';
        control.style.opacity = '0.9';
        control.style.marginLeft = '6px';
        control.innerHTML = `<input type="checkbox" id="recon-auto-open-enrich"> Auto-open enrichment URLs after generation`;
        const reconActions = document.querySelector('.recon-actions');
        if (reconActions) reconActions.appendChild(control);
    }
    
        // expose renderProbableMatches globally for testing
    window.renderProbableMatches = renderProbableMatches;
    
        // Ensure Recon form has a 'Jméno' (name) field; if not present, inject it for better enrichment
    (function ensureReconNameField() {
        const form = document.getElementById('recon-form');
        if (!form) return;
        
        if (!document.getElementById('recon-name')) {
                // Create a new recon-field for name and insert it at the top of form
            const nameField = document.createElement('div');
            nameField.className = 'recon-field';
            nameField.innerHTML = `
                <label for="recon-name">Jméno (volitelné)</label>
                <input id="recon-name" type="text" placeholder="např. Jan Novák">
            `;
                // insert as first child of form
            form.insertBefore(nameField, form.firstChild);
        }
    })();
    
        // Auto-enrich: include name (recon-name) when available
    (function patchAutoEnrichToUseName() {
        const originalAutoEnrich = window.autoEnrich;
        window.autoEnrich = function(usedInputs, byType) {
                // read name if present
            const nameEl = document.getElementById('recon-name');
            const nameVal = nameEl && nameEl.value.trim() ? nameEl.value.trim() : null;
            
                // call original to build base matches
            if (typeof originalAutoEnrich === 'function') {
                originalAutoEnrich(usedInputs, byType);
            }
            
                // Enhance the enrichment rendering: if name is present, prepend a person-search block
            if (!nameVal) return;
            
                // Build person-search URLs combining name + address/username/email local part
            const inputsMap = {};
            usedInputs.forEach(e => inputsMap[e.typeLabel] = e.value);
            
            const personQueries = [];
            if (inputsMap['Adresa']) {
                personQueries.push(encodeURIComponent(nameVal + ' ' + inputsMap['Adresa']));
            }
            if (inputsMap['E-mail']) {
                const local = (inputsMap['E-mail'].split('@')[0] || '').trim();
                if (local) personQueries.push(encodeURIComponent(nameVal + ' ' + local));
            }
            if (inputsMap['Uživatelské jméno']) {
                personQueries.push(encodeURIComponent(nameVal + ' ' + inputsMap['Uživatelské jméno']));
            }
            
            if (!personQueries.length) return;
            
            const resultsEl = document.getElementById('recon-results');
            if (!resultsEl) return;
            
                // create a compact block of person-search queries and render them at the top
            const block = document.createElement('div');
            block.className = 'recon-item recon-person-search';
            
            const title = document.createElement('div');
            title.className = 'recon-group-title';
            title.textContent = '> Person search (name based)';
            block.appendChild(title);
            
            personQueries.forEach(q => {
                const a = document.createElement('a');
                a.href = 'https://www.google.com/search?q=' + q;
                a.target = '_blank';
                a.rel = 'noopener noreferrer';
                a.textContent = decodeURIComponent(q);
                const row = document.createElement('div');
                row.className = 'recon-item-url';
                row.appendChild(a);
                block.appendChild(row);
            });
            
                // insert at top of results
            if (resultsEl.firstChild) {
                resultsEl.insertBefore(block, resultsEl.firstChild);
            } else {
                resultsEl.appendChild(block);
            }
        };
    })();
}

/**
 * buildUrlsForTypeJS – přepis AppleScript `buildUrlsForType`
 * @param {string} tLabel – typ ("Doména", "IP adresa", ...)
 * @param {string} v      – hodnota
 * @returns {string[]}    – seznam URL
 */
function buildUrlsForTypeJS(tLabel, v) {
    const urls = [];
    const q = encodeURIComponent(v);
    
        // univerzální vyhledávače
    urls.push("https://www.google.com/search?q=" + q);
    urls.push("https://duckduckgo.com/?q=" + q);
    urls.push("https://www.bing.com/search?q=" + q);
    urls.push("https://search.seznam.cz/?q=" + q);
    urls.push("https://search.yahoo.com/search?p=" + q);
    
    if (tLabel === "Doména") {
        urls.push("https://crt.sh/?q=" + q);
        urls.push("https://viewdns.info/dnsreport/?domain=" + v);
        urls.push("https://viewdns.info/reverseip/?host=" + v + "&t=1");
        urls.push("https://securitytrails.com/domain/" + v);
        urls.push("https://urlscan.io/search/#" + q);
        urls.push("https://mxtoolbox.com/SuperTool.aspx?action=mx%3a" + v + "&run=toolpage");
        urls.push("https://www.virustotal.com/gui/domain/" + v);
        urls.push("https://www.shodan.io/search?query=" + q);
        urls.push("https://search.censys.io/search?resource=hosts&q=" + q);
        
    } else if (tLabel === "IP adresa") {
        urls.push("https://viewdns.info/ipinfo/?ip=" + v);
        urls.push("https://viewdns.info/iplocation/?ip=" + v);
        urls.push("https://ipinfo.io/" + v);
        urls.push("https://rdap.arin.net/registry/ip/" + v);
        urls.push("https://www.virustotal.com/gui/ip-address/" + v);
        urls.push("https://www.shodan.io/host/" + v);
        urls.push("https://search.censys.io/hosts/" + v);
        urls.push("https://scamalytics.com/ip");
        
    } else if (tLabel === "Uživatelské jméno") {
        const handle = v;
        const encHandle = q;
        
        urls.push("https://github.com/" + handle);
        urls.push("https://x.com/search?q=" + encHandle + "&f=user");
        urls.push("https://www.facebook.com/search/top/?q=" + encHandle);
        urls.push("https://www.instagram.com/" + handle + "/");
        urls.push("https://www.tiktok.com/@" + handle);
        urls.push("https://www.linkedin.com/search/results/all/?keywords=" + encHandle);
        urls.push("https://www.youtube.com/results?search_query=" + encHandle);
        
    } else if (tLabel === "E-mail") {
        urls.push("https://www.google.com/search?q=" + q + "%20\"email\"");
        urls.push("https://duckduckgo.com/?q=" + q + "%20\"email\"");
        urls.push("https://github.com/search?q=" + q);
        urls.push("https://pastebin.com/search?q=" + q);
        
        const atIndex = v.indexOf("@");
        if (atIndex > 0) {
            const mailDomain = v.substring(atIndex + 1);
            const mailDomEnc = encodeURIComponent(mailDomain);
            urls.push("https://www.google.com/search?q=site:outlook.com%20" + mailDomEnc);
            urls.push("https://www.google.com/search?q=site:icloud.com%20" + mailDomEnc);
            urls.push("https://www.google.com/search?q=site:yahoo.com%20" + mailDomEnc);
        }
        
        urls.push("https://haveibeenpwned.com/");
        
    } else if (tLabel === "Telefonní číslo") {
        urls.push("https://www.google.com/search?q=" + q + "%20telefon");
        urls.push("https://duckduckgo.com/?q=" + q + "%20telefon");
        urls.push("https://www.kdomivolal.cz/?q=" + v);
        urls.push("https://www.kdomivolal.eu/hledat/" + v);
        urls.push("https://www.vyhledatcislo.cz/" + v);
        
    } else if (tLabel === "IČO") {
        urls.push("https://www.google.com/search?q=IČO%20" + q);
        urls.push("https://duckduckgo.com/?q=IČO%20" + q);
        urls.push("https://or.justice.cz/ias/ui/rejstrik-%24%C3%BUsel?ico=" + v);
        urls.push("https://resdata.cz/ico/" + v);
        urls.push("https://rejstrik-firem.kurzy.cz/ico/" + v);
        urls.push("https://ares.gov.cz/");
        
    } else if (tLabel === "Adresa") {
        urls.push("https://www.google.com/maps/search/" + q);
        urls.push("https://mapy.cz/zakladni?q=" + q);
        
    } else if (tLabel === "UVID / jiné ID") {
        urls.push("https://www.google.com/search?q=" + q);
        urls.push("https://duckduckgo.com/?q=" + q);
        urls.push("https://www.google.com/search?q=" + q + "%20p%C3%A1tr%C3%A1n%C3%AD%20po%20osob%C3%A1ch");
    }
    
        // pro citlivější typy navíc obecný „pátrání po osobách"
    if (
        tLabel === "Telefonní číslo" ||
        tLabel === "Adresa" ||
        tLabel === "UVID / jiné ID" ||
        tLabel === "E-mail"
        ) {
            urls.push("https://www.google.com/search?q=" + q + "%20p%C3%A1tr%C3%A1n%C3%AD%20po%20osobách");
        }
    
    return urls;
}

    // === SECURE PANEL (antimalware / antispy / network / browser shield) ===
    //
    // UI simulace – reálná ochrana by musela běžet v OS, firewallu, VPN/TOR a pluginu pro browser.
    //
function initSecurity() {
    const procBody = document.getElementById("proc-table-body");
    const connBody = document.getElementById("conn-table-body");
    
    const adblockToggle = document.getElementById("sec-adblock-toggle");
    const blockAiToggle = document.getElementById("sec-block-ai-toggle");
    const trackingRadios = document.querySelectorAll("input[name='tracking-mode']");
    const cookiesEssential = document.getElementById("sec-cookies-essential");
    const cookiesAnalytics = document.getElementById("sec-cookies-analytics");
    const cookiesMarketing = document.getElementById("sec-cookies-marketing");
    const vpnToggle = document.getElementById("sec-vpn-toggle");
    const torToggle = document.getElementById("sec-tor-toggle");
    
    if (!procBody || !connBody) return;
    
        // --- Simulovaná data procesů ---
    const processes = [
        {
name: "systemd",
pid: 1,
cpu: 0.2,
mem: 64,
risk: "low",
tags: ["core", "system"]
        },
        {
name: "nginx",
pid: 452,
cpu: 2.1,
mem: 128,
risk: "low",
tags: ["network", "web"]
        },
        {
name: "chrome.exe",
pid: 2341,
cpu: 8.4,
mem: 1024,
risk: "medium",
tags: ["browser", "network"]
        },
        {
name: "telemetry_client",
pid: 3320,
cpu: 1.2,
mem: 150,
risk: "high",
tags: ["telemetry", "tracking"]
        },
        {
name: "discord.exe",
pid: 2901,
cpu: 3.8,
mem: 512,
risk: "medium",
tags: ["chat", "overlay"]
        },
        {
name: "unknown_updater.exe",
pid: 4103,
cpu: 0.9,
mem: 90,
risk: "high",
tags: ["updater", "unknown-sign"]
        },
        {
name: "wg-quick",
pid: 900,
cpu: 0.3,
mem: 30,
risk: "low",
tags: ["vpn", "wireguard"]
        }
    ];
    
        // --- Simulovaná data spojení ---
    const connections = [
        {
app: "chrome.exe",
remote: "198.51.100.24:443",
country: "US",
status: "blocked",
reason: "Tracker / Ads"
        },
        {
app: "telemetry_client",
remote: "203.0.113.77:443",
country: "US",
status: "blocked",
reason: "Telemetry endpoint"
        },
        {
app: "nginx",
remote: "0.0.0.0:443",
country: "Local",
status: "allowed",
reason: "Listening (reverse proxy)"
        },
        {
app: "wg-quick",
remote: "192.0.2.10:51820",
country: "VPN",
status: "allowed",
reason: "VPN tunnel"
        },
        {
app: "chrome.exe",
remote: "93.184.216.34:443",
country: "US",
status: "allowed",
reason: "Web browsing"
        }
    ];
    
    const securityState = {
        adblock: true,
        blockAi: true,
        trackingMode: "balanced",
        cookiesEssential: true,
        cookiesAnalytics: false,
        cookiesMarketing: false,
        vpnEnabled: true,
        torEnabled: false
    };
    
        // --- Helper pro update textů na dashboardu + secure panelu ---
    const setSecField = (field, text) => {
        document.querySelectorAll(`[data-sec="${field}"]`).forEach(el => {
            el.textContent = text;
        });
    };
    
        // --- Render procesů ---
    function renderProcesses() {
        procBody.innerHTML = "";
        processes.forEach(proc => {
            const tr = document.createElement("tr");
            if (proc.risk === "high") {
                tr.className = "proc-row-high";
            } else if (proc.risk === "medium") {
                tr.className = "proc-row-medium";
            } else {
                tr.className = "proc-row-low";
            }
            
            const riskClass =
            proc.risk === "high"
            ? "proc-risk-high"
            : proc.risk === "medium"
            ? "proc-risk-medium"
            : "proc-risk-low";
            
            tr.innerHTML = `
                    <td>${proc.name}</td>
                    <td>${proc.pid}</td>
                    <td>${proc.cpu.toFixed(1)}</td>
                    <td>${proc.mem}</td>
                    <td class="${riskClass}">${proc.risk.toUpperCase()}</td>
                    <td>${proc.tags
                    .map(t => `<span class="badge-pill">${t}</span>`) 
                    .join(" ")}</td>
            `;
            procBody.appendChild(tr);
        });
    }
    
        // --- Render spojení ---
    function renderConnections() {
        connBody.innerHTML = "";
        connections.forEach(conn => {
            const tr = document.createElement("tr");
            const statusClass =
            conn.status === "blocked"
            ? "conn-status conn-status-blocked"
            : "conn-status conn-status-allowed";
            
            tr.innerHTML = `
                <td>${conn.app}</td>
                <td>${conn.remote}</td>
                <td>${conn.country}</td>
                <td class="${statusClass}">${conn.status.toUpperCase()}</td>
                <td>${conn.reason}</td>
            `;
            connBody.appendChild(tr);
        });
    }
    
        // --- Výpočet souhrnných hodnot ---
    function updateSecuritySummary() {
        const suspiciousCount = processes.filter(p => p.risk === "high").length;
        const blockedCount = connections.filter(c => c.status === "blocked").length;
        
        setSecField("suspicious-count", String(suspiciousCount));
        setSecField("blocked-count", String(blockedCount));
        
        const trackingLabel = (() => {
            if (securityState.trackingMode === "strict") return "Strict";
            if (securityState.trackingMode === "custom") {
                if (!securityState.cookiesMarketing && !securityState.cookiesAnalytics && securityState.blockAi && securityState.adblock) {
                    return "Custom (strong)";
                }
                return "Custom";
            }
            return "Balanced";
        })();
        
        setSecField("tracking-level", trackingLabel);
        
        const routeMode = (() => {
            if (securityState.vpnEnabled && securityState.torEnabled) return "TOR over VPN";
            if (securityState.vpnEnabled) return "VPN only";
            if (securityState.torEnabled) return "TOR only";
            return "Direct (warning)";
        })();
        setSecField("route-mode", routeMode);
        
        const antimalwareStatus = "Aktivní (Realtime shield)";
        setSecField("antimalware-status", antimalwareStatus);
        
        const lastScanText = new Date().toLocaleString("cs-CZ");
        setSecField("last-scan", lastScanText);
        setSecField("vpn-status", securityState.vpnEnabled ? "Connected" : "Disconnected");
    }
    
        // --- Eventy pro Browser shield / routing / cookies ---
    if (adblockToggle) {
        adblockToggle.checked = securityState.adblock;
        adblockToggle.addEventListener("change", () => {
            securityState.adblock = adblockToggle.checked;
            logEvent(`Adblock ${securityState.adblock ? "enabled" : "disabled"}`);
            updateSecuritySummary();
        });
    }
    
    if (blockAiToggle) {
        blockAiToggle.checked = securityState.blockAi;
        blockAiToggle.addEventListener("change", () => {
            securityState.blockAi = blockAiToggle.checked;
            logEvent(`AI trackbot blocking ${securityState.blockAi ? "enabled" : "disabled"}`);
            updateSecuritySummary();
        });
    }
    
    trackingRadios.forEach(radio => {
        if (radio.value === securityState.trackingMode) {
            radio.checked = true;
        }
        radio.addEventListener("change", () => {
            if (radio.checked) {
                securityState.trackingMode = radio.value;
                logEvent(`Tracking mode set to: ${radio.value}`);
                updateSecuritySummary();
            }
        });
    });
    
    if (cookiesEssential) {
        cookiesEssential.checked = securityState.cookiesEssential;
    }
    if (cookiesAnalytics) {
        cookiesAnalytics.checked = securityState.cookiesAnalytics;
        cookiesAnalytics.addEventListener("change", () => {
            securityState.cookiesAnalytics = cookiesAnalytics.checked;
            logEvent(`Analytics cookies ${securityState.cookiesAnalytics ? "allowed" : "blocked"}`);
            updateSecuritySummary();
        });
    }
    if (cookiesMarketing) {
        cookiesMarketing.checked = securityState.cookiesMarketing;
        cookiesMarketing.addEventListener("change", () => {
            securityState.cookiesMarketing = cookiesMarketing.checked;
            logEvent(`Marketing cookies ${securityState.cookiesMarketing ? "allowed" : "blocked"}`);
            updateSecuritySummary();
        });
    }
    
    if (vpnToggle) {
        vpnToggle.checked = securityState.vpnEnabled;
        vpnToggle.addEventListener("change", () => {
            securityState.vpnEnabled = vpnToggle.checked;
            logEvent(`VPN toggle: ${securityState.vpnEnabled ? "ON" : "OFF"} (UI only)`);
            updateSecuritySummary();
        });
    }
    
    if (torToggle) {
        torToggle.checked = securityState.torEnabled;
        torToggle.addEventListener("change", () => {
            securityState.torEnabled = torToggle.checked;
            logEvent(`TOR toggle: ${securityState.torEnabled ? "ON" : "OFF"} (UI only)`);
            updateSecuritySummary();
        });
    }
    
        // Inicializace
    renderProcesses();
    renderConnections();
    updateSecuritySummary();
}

    // --- AUTO-ENRICHMENT HELPERS (client-side heuristics, no scraping) ---
function normalizePhone(input) {
    if (!input) return "";
    const cleaned = input.replace(/[^\d+]/g, "");
    if (!cleaned.startsWith("+") && cleaned.length === 9) {
        return "+420" + cleaned;
    }
    return cleaned;
}

function localPartOfEmail(email) {
    if (!email) return "";
    const idx = email.indexOf("@");
    return idx > 0 ? email.substring(0, idx) : email;
}

function generateHandleVariants(nameOrHandle) {
    if (!nameOrHandle) return [];
    const base = nameOrHandle.trim().toLowerCase().replace(/\s+/g, "");
    const variants = new Set();
    variants.add(base);
    variants.add(base.replace(/\./g, ""));
    variants.add(base.replace(/[^a-z0-9]/g, ""));
    variants.add(base + "1");
    variants.add(base + "_official");
    variants.add(base + ".");
    if (nameOrHandle.includes(" ")) {
        const parts = nameOrHandle.toLowerCase().split(/\s+/);
        variants.add(parts.join("."));
        variants.add(parts.join("_"));
    }
    return Array.from(variants).slice(0, 8);
}

function buildProfileUrlsForHandle(handle) {
    if (!handle) return [];
    const enc = encodeURIComponent(handle);
    return [
        `https://github.com/${handle}`,
        `https://x.com/${handle}`,
        `https://x.com/search?q=${enc}&f=user`,
        `https://www.instagram.com/${handle}/`,
        `https://www.tiktok.com/@${handle}`,
        `https://www.youtube.com/results?search_query=${enc}`,
        `https://www.linkedin.com/search/results/all/?keywords=${enc}`
    ];
}

function renderProbableMatches(containerEl, matches) {
    if (!containerEl) return;
    const wrapper = document.createElement("div");
    wrapper.className = "recon-probable-matches";
    
    const title = document.createElement("div");
    title.className = "recon-group-title";
    title.textContent = "> Pravděpodobné shody / enrichment";
    wrapper.appendChild(title);
    
    if (!matches.length) {
        const none = document.createElement("div");
        none.className = "recon-item";
        none.textContent = "Nebyla nalezena žádná automatická shoda (heuristicky).";
        wrapper.appendChild(none);
        containerEl.appendChild(wrapper);
        return;
    }
    
    matches.forEach(m => {
        const item = document.createElement("div");
        item.className = "recon-item";
        
        const header = document.createElement("div");
        header.style.marginBottom = "6px";
        header.innerHTML = `<strong>${m.label}</strong> <span style="opacity:0.85">(${m.kind})</span>`;
        item.appendChild(header);
        
        if (m.urls && m.urls.length) {
            const list = document.createElement("div");
            list.className = "recon-item-url";
            m.urls.forEach(u => {
                const a = document.createElement("a");
                a.href = u;
                a.target = "_blank";
                a.rel = "noopener noreferrer";
                a.textContent = u;
                list.appendChild(a);
                list.appendChild(document.createElement("br"));
            });
            item.appendChild(list);
        } else if (m.value) {
            const vdiv = document.createElement("div");
            vdiv.textContent = m.value;
            item.appendChild(vdiv);
        }
        
        wrapper.appendChild(item);
    });
    
    containerEl.appendChild(wrapper);
}

function autoEnrich(usedInputs, byType) {
    const inputMap = {};
    usedInputs.forEach(e => inputMap[e.typeLabel] = e.value);
    
    const matches = [];
    
    const email = inputMap["E-mail"] || "";
    const emailLocal = localPartOfEmail(email);
    if (emailLocal) {
        const variants = generateHandleVariants(emailLocal);
        const urls = [];
        variants.forEach(h => urls.push(...buildProfileUrlsForHandle(h)));
        matches.push({ kind: "profile", label: `Na základě e‑mailu: ${emailLocal}`, urls: Array.from(new Set(urls)).slice(0, 12) });
    }
    
    const username = inputMap["Uživatelské jméno"] || "";
    if (username) {
        const variants = generateHandleVariants(username);
        const urls = [];
        variants.forEach(h => urls.push(...buildProfileUrlsForHandle(h)));
        matches.push({ kind: "profile", label: `Zadané uživatelské jméno: ${username}`, urls: Array.from(new Set(urls)).slice(0, 12) });
    }
    
    const address = inputMap["Adresa"] || "";
    if (address && (username || emailLocal)) {
        const q = encodeURIComponent((username || emailLocal) + " " + address);
        const urls = [
            `https://www.google.com/search?q=${q}`,
            `https://duckduckgo.com/?q=${q}`,
            `https://www.bing.com/search?q=${q}`
        ];
        matches.push({ kind: "search", label: `Osobní pátrání pro: ${(username || emailLocal)} + adresa`, urls });
    }
    
    const phone = inputMap["Telefonní číslo"] || "";
    const normalizedPhone = normalizePhone(phone);
    if (normalizedPhone) {
        const urls = [
            `https://www.google.com/search?q=${encodeURIComponent(normalizedPhone)}`,
            `https://duckduckgo.com/?q=${encodeURIComponent(normalizedPhone)}`,
            `https://www.kdomivolal.cz/?q=${encodeURIComponent(normalizedPhone)}`
        ];
        matches.push({ kind: "phone", label: `Normalizované tel.: ${normalizedPhone}`, urls });
    }
    
    if (email) {
        const domain = email.split("@")[1];
        if (domain) {
            const domEnc = encodeURIComponent(domain);
            const urls = [
                `https://www.google.com/search?q=site:linkedin.com+${domEnc}`,
                `https://www.google.com/search?q=site:github.com+${domEnc}`,
                `https://www.google.com/search?q=site:instagram.com+${domEnc}`
            ];
            matches.push({ kind: "org", label: `Hledání dle domény: ${domain}`, urls });
        }
    }
    
    const resultsEl = document.getElementById("recon-results");
    if (!resultsEl) return;
    
        // render and also update lastEnrichmentMatches if present in scope
    if (typeof window.renderProbableMatches === 'function') {
        window.renderProbableMatches(resultsEl, matches);
    } else {
        renderProbableMatches(resultsEl, matches);
    }
}

    // End of script.js
