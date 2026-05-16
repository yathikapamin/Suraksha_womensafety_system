// SafeNet AI Admin Panel - Main Application Controller

document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  loadDashboard();
  loadUsers();
  loadAlerts();
  loadVerifications();
  loadEmergencies();
  loadResponders();
});

// ═══ NAVIGATION ═══
function initNavigation() {
  document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', () => {
      document.querySelectorAll('.nav-item').forEach(i => i.classList.remove('active'));
      item.classList.add('active');
      const page = item.dataset.page;
      document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
      document.getElementById(`page-${page}`).classList.add('active');
    });
  });
}

// ═══ DASHBOARD ═══
function loadDashboard() {
  // Users count
  db.collection('users').get().then(snap => {
    document.getElementById('totalUsers').textContent = snap.size;
    const verified = snap.docs.filter(d => d.data().is_verified).length;
    document.getElementById('verifiedUsers').textContent = verified;
  });

  // Active alerts
  db.collection('alerts').where('status', '==', 'active').get().then(snap => {
    document.getElementById('activeAlerts').textContent = snap.size;
    document.getElementById('emergencyBadge').textContent = snap.size;
  });

  // Resolved today
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  db.collection('alerts').where('status', '==', 'resolved').get().then(snap => {
    document.getElementById('resolvedAlerts').textContent = snap.size;
  });

  // Recent alerts list
  db.collection('alerts').orderBy('timestamp', 'desc').limit(5).get().then(snap => {
    const list = document.getElementById('recentAlertsList');
    list.innerHTML = '';
    if (snap.empty) { list.innerHTML = '<p style="color:#6B7280;text-align:center;padding:20px">No alerts yet</p>'; return; }
    snap.docs.forEach(doc => {
      const d = doc.data();
      const dotClass = d.status === 'active' ? 'dot-red' : 'dot-green';
      list.innerHTML += `<div class="list-item">
        <div class="dot ${dotClass}"></div>
        <div style="flex:1">
          <div style="color:#fff;font-size:13px;font-weight:500">Alert ${doc.id.substring(0,8)}</div>
          <div style="font-size:12px;color:#6B7280">Risk: ${Math.round((d.risk_score||0)*100)}%</div>
        </div>
        <span class="status-badge status-${d.status}">${(d.status||'').toUpperCase()}</span>
      </div>`;
    });
  });

  // Pending verifications
  db.collection('verification_requests').where('status', '==', 'pending').get().then(snap => {
    const list = document.getElementById('pendingVerifications');
    list.innerHTML = '';
    if (snap.empty) { list.innerHTML = '<p style="color:#6B7280;text-align:center;padding:20px">No pending requests</p>'; return; }
    snap.docs.forEach(doc => {
      const d = doc.data();
      list.innerHTML += `<div class="list-item">
        <div class="dot dot-yellow"></div>
        <div style="flex:1"><div style="color:#fff;font-size:13px">User ${doc.id.substring(0,8)}</div></div>
        <span class="status-badge status-pending">PENDING</span>
      </div>`;
    });
  });
}

// ═══ USERS ═══
function loadUsers() {
  db.collection('users').get().then(snap => {
    const tbody = document.getElementById('usersTableBody');
    tbody.innerHTML = '';
    snap.docs.forEach(doc => {
      const d = doc.data();
      const roleClass = d.role === 'responder' ? 'status-responder' : 'status-user';
      tbody.innerHTML += `<tr>
        <td style="color:#fff;font-weight:500">${d.name || 'N/A'}</td>
        <td>${d.email || ''}</td>
        <td>${d.phone || ''}</td>
        <td><span class="status-badge ${roleClass}">${(d.role||'user').toUpperCase()}</span></td>
        <td><span class="status-badge ${d.is_verified?'status-verified':'status-pending'}">${d.is_verified?'VERIFIED':'NO'}</span></td>
        <td>${(d.trust_score||0).toFixed(1)}</td>
        <td><button class="btn-sm btn-view" onclick="viewUser('${doc.id}')">View</button></td>
      </tr>`;
    });
  });

  // Search
  document.getElementById('userSearch')?.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase();
    document.querySelectorAll('#usersTableBody tr').forEach(row => {
      row.style.display = row.textContent.toLowerCase().includes(query) ? '' : 'none';
    });
  });
}

function viewUser(uid) { alert(`User ID: ${uid}\nView full profile in Firestore console.`); }

// ═══ ALERTS ═══
function loadAlerts() {
  db.collection('alerts').orderBy('timestamp', 'desc').get().then(snap => {
    const tbody = document.getElementById('alertsTableBody');
    tbody.innerHTML = '';
    snap.docs.forEach(doc => {
      const d = doc.data();
      const time = d.timestamp?.toDate?.() ? d.timestamp.toDate().toLocaleString() : 'N/A';
      tbody.innerHTML += `<tr>
        <td style="font-family:monospace;font-size:12px">${doc.id.substring(0,8)}</td>
        <td>${d.user_name || d.user_id?.substring(0,8) || 'N/A'}</td>
        <td><span style="color:${d.risk_score>=0.6?'#EF4444':'#10B981'};font-weight:600">${Math.round((d.risk_score||0)*100)}%</span></td>
        <td style="font-size:12px">${(d.latitude||0).toFixed(4)}, ${(d.longitude||0).toFixed(4)}</td>
        <td><span class="status-badge status-${d.status}">${(d.status||'').toUpperCase()}</span></td>
        <td style="font-size:12px">${time}</td>
        <td>${d.status==='active'?`<button class="btn-sm btn-approve" onclick="resolveAlert('${doc.id}')">Resolve</button>`:'-'}</td>
      </tr>`;
    });
  });
}

function resolveAlert(alertId) {
  db.collection('alerts').doc(alertId).update({
    status: 'resolved',
    resolved_by: 'admin',
    resolved_at: firebase.firestore.Timestamp.now()
  }).then(() => { loadAlerts(); loadDashboard(); });
}

// ═══ VERIFICATIONS ═══
function loadVerifications() {
  db.collection('verification_requests').get().then(snap => {
    const container = document.getElementById('verificationList');
    container.innerHTML = '';
    if (snap.empty) { container.innerHTML = '<div class="card" style="text-align:center;color:#6B7280">No verification requests</div>'; return; }
    snap.docs.forEach(doc => {
      const d = doc.data();
      container.innerHTML += `<div class="verification-card">
        <div class="user-info">
          <div class="avatar">${(d.user_id||'U')[0].toUpperCase()}</div>
          <div><div style="color:#fff;font-weight:500">User ${doc.id.substring(0,8)}</div>
          <div style="font-size:12px;color:#6B7280">Status: ${d.status}</div></div>
        </div>
        <div class="images">
          ${d.id_proof_url?`<img src="${d.id_proof_url}" alt="ID Proof">`:'<div style="background:rgba(255,255,255,0.05);border-radius:10px;height:100px;display:flex;align-items:center;justify-content:center;color:#6B7280">No ID</div>'}
          ${d.selfie_url?`<img src="${d.selfie_url}" alt="Selfie">`:'<div style="background:rgba(255,255,255,0.05);border-radius:10px;height:100px;display:flex;align-items:center;justify-content:center;color:#6B7280">No Selfie</div>'}
        </div>
        <div class="actions">
          <button class="btn-sm btn-approve" onclick="approveVerification('${doc.id}')">✅ Approve</button>
          <button class="btn-sm btn-reject" onclick="rejectVerification('${doc.id}')">❌ Reject</button>
        </div>
      </div>`;
    });
  });
}

function approveVerification(userId) {
  db.collection('verification_requests').doc(userId).update({ status: 'approved', reviewed_at: firebase.firestore.Timestamp.now() });
  db.collection('users').doc(userId).update({ is_verified: true, trust_score: 3.0 });
  loadVerifications(); loadDashboard();
}

function rejectVerification(userId) {
  db.collection('verification_requests').doc(userId).update({ status: 'rejected', reviewed_at: firebase.firestore.Timestamp.now() });
  loadVerifications();
}

// ═══ EMERGENCIES ═══
function loadEmergencies() {
  db.collection('alerts').where('status', '==', 'active').onSnapshot(snap => {
    const container = document.getElementById('emergenciesList');
    document.getElementById('emergencyBadge').textContent = snap.size;
    container.innerHTML = '';
    if (snap.empty) { container.innerHTML = '<div class="card" style="text-align:center;color:#6B7280;padding:40px">✅ No active emergencies</div>'; return; }
    snap.docs.forEach(doc => {
      const d = doc.data();
      const time = d.timestamp?.toDate?.() ? d.timestamp.toDate().toLocaleString() : 'N/A';
      container.innerHTML += `<div class="emergency-card">
        <h4>🚨 Emergency Alert</h4>
        <p style="margin-bottom:8px"><strong style="color:#fff">${d.user_name||'Unknown'}</strong> needs help!</p>
        <p style="font-size:13px">Risk: <strong style="color:#EF4444">${Math.round((d.risk_score||0)*100)}%</strong></p>
        <p style="font-size:13px">Location: ${(d.latitude||0).toFixed(4)}, ${(d.longitude||0).toFixed(4)}</p>
        <p style="font-size:12px;color:#6B7280;margin-top:6px">Time: ${time}</p>
        <p style="font-size:12px;margin-top:4px">Responders notified: ${(d.notified_responders||[]).length}</p>
        <div style="margin-top:12px;display:flex;gap:8px">
          <a href="https://www.openstreetmap.org/?mlat=${d.latitude}&mlon=${d.longitude}#map=18/${d.latitude}/${d.longitude}" target="_blank" class="btn-sm btn-view">📍 View Map</a>
          <button class="btn-sm btn-approve" onclick="resolveAlert('${doc.id}')">✅ Resolve</button>
        </div>
      </div>`;
    });
  });
}

// ═══ RESPONDERS ═══
function loadResponders() {
  db.collection('users').where('role', '==', 'responder').get().then(snap => {
    const tbody = document.getElementById('respondersTableBody');
    tbody.innerHTML = '';
    if (snap.empty) { tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;color:#6B7280">No responders yet</td></tr>'; return; }
    snap.docs.forEach(doc => {
      const d = doc.data();
      tbody.innerHTML += `<tr>
        <td style="color:#fff;font-weight:500">${d.name||'N/A'}</td>
        <td>${d.phone||''}</td>
        <td><span class="status-badge ${d.is_verified?'status-verified':'status-pending'}">${d.is_verified?'VERIFIED':'PENDING'}</span></td>
        <td>${(d.trust_score||0).toFixed(1)}/5.0</td>
        <td style="font-size:12px">${(d.latitude||0).toFixed(4)}, ${(d.longitude||0).toFixed(4)}</td>
        <td><button class="btn-sm btn-view" onclick="viewUser('${doc.id}')">View</button></td>
      </tr>`;
    });
  });
}

// Logout
document.getElementById('logoutBtn')?.addEventListener('click', () => {
  auth.signOut().then(() => alert('Logged out'));
});
