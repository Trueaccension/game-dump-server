const http = require('http');
const fs = require('fs');
const path = require('path');

const STORAGE_DIR = path.join(__dirname, 'game_dumps');
if (!fs.existsSync(STORAGE_DIR)) fs.mkdirSync(STORAGE_DIR, { recursive: true });

const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') { res.writeHead(200); res.end(); return; }

    if (req.method === 'GET' && req.url === '/') {
        const files = fs.existsSync(STORAGE_DIR) ? fs.readdirSync(STORAGE_DIR) : [];
        let html = '<html><head><title>Game Dump Server</title>';
        html += '<style>body{font-family:monospace;background:#1a1a2e;color:#0f0;padding:20px}';
        html += 'a{color:#0ff}h1{color:#fff}.file{margin:5px 0;padding:8px;background:#16213e;border-radius:4px}</style></head>';
        html += '<body><h1>Game Dump Server</h1><p>Status: ONLINE</p><p>Files: ' + files.length + '</p><h2>Downloads:</h2>';
        const fd = files.map(f => {
            const s = fs.statSync(path.join(STORAGE_DIR, f));
            return { name: f, size: s.size, time: s.mtimeMs };
        }).sort((a, b) => b.time - a.time);
        fd.forEach(f => {
            html += '<div class="file"><a href="/download/' + encodeURIComponent(f.name) + '">' + f.name + '</a> (' + (f.size/1024/1024).toFixed(2) + ' MB)</div>';
        });
        html += '</body></html>';
        res.writeHead(200, { 'Content-Type': 'text/html' }); res.end(html); return;
    }

    if (req.method === 'GET' && req.url.startsWith('/download/')) {
        const fn = decodeURIComponent(req.url.replace('/download/', ''));
        const fp = path.join(STORAGE_DIR, fn);
        if (!fp.startsWith(STORAGE_DIR)) { res.writeHead(403); res.end('Forbidden'); return; }
        if (fs.existsSync(fp)) {
            const s = fs.statSync(fp);
            res.writeHead(200, { 'Content-Type': 'application/octet-stream', 'Content-Disposition': 'attachment; filename="' + fn + '"', 'Content-Length': s.size });
            fs.createReadStream(fp).pipe(res);
        } else { res.writeHead(404); res.end('Not found'); }
        return;
    }

    if (req.method === 'POST' && req.url === '/upload') {
        let body = [];
        req.on('data', c => body.push(c));
        req.on('end', () => {
            try {
                const raw = Buffer.concat(body).toString();
                let data;
                try { data = JSON.parse(raw); } catch(e) {
                    const fn = 'raw_' + Date.now() + '.bin';
                    fs.writeFileSync(path.join(STORAGE_DIR, fn), raw);
                    res.writeHead(200, {'Content-Type':'application/json'}); res.end(JSON.stringify({success:true,filename:fn})); return;
                }
                const fn = (data.filename || 'dump_' + Date.now() + '.json').replace(/[^a-zA-Z0-9._-]/g, '_');
                fs.writeFileSync(path.join(STORAGE_DIR, fn), data.content || raw);
                console.log('Saved: ' + fn + ' (' + (Buffer.byteLength(data.content||raw)/1024).toFixed(1) + ' KB)');
                res.writeHead(200, {'Content-Type':'application/json'}); res.end(JSON.stringify({success:true,filename:fn}));
            } catch(e) { res.writeHead(500); res.end(JSON.stringify({success:false,error:e.message})); }
        });
        return;
    }

    if (req.method === 'POST' && req.url.startsWith('/upload-binary')) {
        let body = [];
        req.on('data', c => body.push(c));
        req.on('end', () => {
            try {
                const buf = Buffer.concat(body);
                const url = new URL(req.url, 'http://localhost');
                const fn = (url.searchParams.get('name') || 'binary_' + Date.now()).replace(/[^a-zA-Z0-9._-]/g, '_');
                fs.writeFileSync(path.join(STORAGE_DIR, fn), buf);
                console.log('Binary: ' + fn + ' (' + (buf.length/1024).toFixed(1) + ' KB)');
                res.writeHead(200, {'Content-Type':'application/json'}); res.end(JSON.stringify({success:true,filename:fn,size:buf.length}));
            } catch(e) { res.writeHead(500); res.end(JSON.stringify({success:false,error:e.message})); }
        });
        return;
    }

    if (req.method === 'POST' && req.url === '/clear') {
        const files = fs.readdirSync(STORAGE_DIR);
        files.forEach(f => fs.unlinkSync(path.join(STORAGE_DIR, f)));
        res.writeHead(200, {'Content-Type':'application/json'}); res.end(JSON.stringify({success:true,deleted:files.length})); return;
    }

    res.writeHead(404); res.end('Not found');
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log('Game Dump Server on port ' + PORT));
