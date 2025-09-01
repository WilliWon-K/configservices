<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayWide=true; section>
<#if section = "header">
  <!-- Header SonarQube personnalisé -->
<#elseif section = "form">
  <canvas id="bubbles-bg"></canvas>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700&display=swap');
    :root {
      --sonar-blue: #00b4ef;
      --sonar-dark: #232f3e;
      --sonar-light: #f4f8fb;
      --sonar-gray: #b0b8c1;
      --sonar-accent: #00e6c3;
      --sonar-shadow: 0 8px 32px 0 rgba(0, 180, 239, 0.10);
    }
    body {
      background: linear-gradient(135deg, var(--sonar-blue) 0%, var(--sonar-accent) 100%) !important;
      font-family: 'Montserrat', Arial, sans-serif !important;
      min-height: 100vh;
      margin: 0;
      overflow: hidden;
      position: relative;
    }
    #bubbles-bg {
      position: fixed;
      top: 0; left: 0;
      width: 100vw; height: 100vh;
      z-index: 0;
      pointer-events: auto;
      display: block;
    }
    .sq-center-wrap {
      min-height: 100vh;
      width: 100vw;
      display: flex;
      align-items: center;
      justify-content: flex-end;
      padding-right: 6vw;
      box-sizing: border-box;
      position: relative;
      z-index: 1;
    }
    .sq-container {
      background: var(--sonar-light);
      border-radius: 32px;
      box-shadow: var(--sonar-shadow);
      max-width: 420px;
      width: 100%;
      padding: 48px 36px 36px 36px;
      margin: 32px 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      position: relative;
    }
    .sq-logo {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-bottom: 24px;
    }
    .sq-logo img {
      width: 120px;
      height: auto;
      display: block;
      margin: 0 auto 8px auto;
    }
    .sq-logo-title {
      font-size: 2.1rem;
      font-weight: 700;
      color: var(--sonar-dark);
      letter-spacing: -0.03em;
      text-align: center;
    }
    .sq-logo-sub {
      font-size: 1.1rem;
      color: var(--sonar-blue);
      font-weight: 600;
      margin-top: 2px;
      letter-spacing: 0.04em;
      text-align: center;
    }
    .sq-switcher {
      display: flex;
      width: 100%;
      margin-bottom: 28px;
      border-radius: 24px;
      background: var(--sonar-gray);
      overflow: hidden;
    }
    .sq-switch-btn {
      flex: 1;
      padding: 14px 0;
      background: transparent;
      border: none;
      color: #fff;
      font-size: 1rem;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.2s, color 0.2s;
      border-radius: 0;
    }
    .sq-switch-btn.active {
      background: var(--sonar-blue);
      color: #fff;
    }
    .sq-form-title {
      font-size: 1.15rem;
      color: var(--sonar-dark);
      font-weight: 600;
      margin-bottom: 24px;
      text-align: center;
    }
    .sq-form {
      width: 100%;
      display: none;
      flex-direction: column;
      gap: 18px;
      animation: fadeIn 0.3s;
      align-items: center;
    }
    .sq-form.active {
      display: flex;
    }
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(10px);}
      to { opacity: 1; transform: translateY(0);}
    }
    .sq-field {
      display: flex;
      flex-direction: column;
      align-items: center;
      width: 100%;
    }
    .sq-label {
      width: 100%;
      text-align: center;
      color: var(--sonar-dark);
      font-weight: 500;
      margin-bottom: 6px;
    }
    .sq-input {
      width: 100%;
      max-width: 320px;
      padding: 14px 16px;
      border-radius: 18px;
      border: 1.5px solid var(--sonar-gray);
      background: #fff;
      font-size: 1rem;
      color: var(--sonar-dark);
      transition: border 0.2s;
      outline: none;
      box-sizing: border-box;
      margin-bottom: 0;
    }
    .sq-input:focus {
      border-color: var(--sonar-blue);
    }
    .sq-logo-img {
      width: 120px;
      height: auto;
      display: block;
      margin: 0 auto 8px auto;
      background: none;
      border-radius: 0;
      box-shadow: none;
    }
    .sq-role-group {
      display: flex;
      gap: 10px;
      margin-top: 4px;
    }
    .sq-role-radio {
      display: none;
    }
    .sq-role-label {
      padding: 10px 18px;
      border-radius: 16px;
      border: 1.5px solid var(--sonar-gray);
      background: #fff;
      color: var(--sonar-dark);
      font-size: 0.98rem;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
    }
    .sq-role-radio:checked + .sq-role-label {
      background: var(--sonar-blue);
      color: #fff;
      border-color: var(--sonar-blue);
    }
    .sq-btn {
      width: 100%;
      padding: 16px 0;
      border-radius: 32px;
      border: none;
      background: var(--sonar-blue);
      color: #fff;
      font-size: 1.1rem;
      font-weight: 700;
      cursor: pointer;
      margin-top: 10px;
      box-shadow: 0 2px 8px 0 rgba(0,180,239,0.08);
      transition: background 0.2s, transform 0.1s;
    }
    .sq-btn:hover {
      background: var(--sonar-accent);
      color: var(--sonar-dark);
      transform: translateY(-2px);
    }
    .sq-btn-secondary {
      background: #fff;
      color: var(--sonar-blue);
      border: 1.5px solid var(--sonar-blue);
      margin-top: 0;
    }
    .sq-btn-secondary:hover {
      background: var(--sonar-blue);
      color: #fff;
    }
    .sq-link {
      color: var(--sonar-blue);
      text-decoration: none;
      font-size: 0.98rem;
      margin-top: 10px;
      display: inline-block;
      transition: color 0.2s;
      cursor: pointer;
    }
    .sq-link:hover {
      color: var(--sonar-accent);
      text-decoration: underline;
    }
    .sq-error {
      color: #e94e77;
      font-size: 0.98rem;
      margin-top: 6px;
      display: none;
    }
    .sq-error.show {
      display: block;
    }
    .sq-reset-form {
      display: none;
      flex-direction: column;
      gap: 14px;
      margin-top: 18px;
      width: 100%;
      animation: fadeIn 0.3s;
    }
    .sq-reset-form.active {
      display: flex;
    }
    @media (max-width: 600px) {
      .sq-container { padding: 24px 8px 18px 8px; border-radius: 18px;}
      .sq-logo img { width: 80px;}
    }
  </style>
  <div class="sq-center-wrap">
    <div class="sq-container">
      <div class="sq-logo">
        <img src="https://images.seeklogo.com/logo-png/46/1/sonarqube-logo-png_seeklogo-467003.png" alt="SonarQube Logo" />
        <span class="sq-logo-title">SonarQube</span>
        <span class="sq-logo-sub">Quality Gate Portal</span>
      </div>
      <div class="sq-switcher">
        <button type="button" class="sq-switch-btn active" onclick="sqSwitch('login')">Connexion</button>
        <button type="button" class="sq-switch-btn" onclick="sqSwitch('register')">Inscription</button>
      </div>
      <div class="sq-form-title" id="sq-form-title">Connectez-vous à SonarQube</div>
      <!-- Login Form -->
      <form id="sq-login-form" class="sq-form active" action="${url.loginAction}" method="post" autocomplete="off">
        <div class="sq-field">
          <label class="sq-label" for="sq-username">Utilisateur ou Email</label>
          <input class="sq-input" id="sq-username" name="username" type="text" placeholder="ex: alice@entreprise.com" required autofocus />
        </div>
        <div class="sq-field">
          <label class="sq-label" for="sq-password">Mot de passe</label>
          <input class="sq-input" id="sq-password" name="password" type="password" placeholder="Votre mot de passe" required />
        </div>
        <div style="display:flex;justify-content:space-between;align-items:center;width:100%;margin-top:2px;">
          <label style="display:flex;align-items:center;gap:8px;">
            <input type="checkbox" name="rememberMe" style="accent-color:var(--sonar-blue);width:18px;height:18px;">
            <span style="color:var(--sonar-dark);font-size:0.98rem;">Se souvenir de moi</span>
          </label>
          <span class="sq-link" onclick="showResetForm()">Mot de passe oublié ?</span>
        </div>
        <button type="submit" class="sq-btn">Se connecter</button>
      </form>
      <!-- Reset Password Form -->
      <form id="sq-reset-form" class="sq-reset-form" method="post" action="${url.loginResetCredentialsUrl}">
        <div class="sq-field">
          <label class="sq-label" for="sq-reset-email">Votre email professionnel</label>
          <input class="sq-input" id="sq-reset-email" name="email" type="email" placeholder="alice@entreprise.com" required />
        </div>
        <button type="submit" class="sq-btn">Envoyer le lien de réinitialisation</button>
        <button type="button" class="sq-btn sq-btn-secondary" onclick="hideResetForm()">Annuler</button>
      </form>
      <!-- Register Form -->
      <form id="sq-register-form" class="sq-form" method="post" autocomplete="off">
        <div class="sq-field">
          <label class="sq-label" for="sq-fullname">Nom complet</label>
          <input class="sq-input" id="sq-fullname" name="fullname" type="text" placeholder="Alice Martin" required />
        </div>
        <div class="sq-field">
          <label class="sq-label" for="sq-email">Email professionnel</label>
          <input class="sq-input" id="sq-email" name="email" type="email" placeholder="alice@entreprise.com" required />
        </div>
        <div class="sq-field">
          <label class="sq-label" for="sq-newpass">Mot de passe</label>
          <input class="sq-input" id="sq-newpass" name="password" type="password" placeholder="Créer un mot de passe" required />
        </div>
        <div class="sq-field">
          <label class="sq-label" for="sq-confirmpass">Confirmer le mot de passe</label>
          <input class="sq-input" id="sq-confirmpass" name="confirmpass" type="password" placeholder="Confirmez le mot de passe" required />
          <div id="sq-passmatch" class="sq-error"></div>
        </div>
        <div class="sq-field">
          <label class="sq-label">Rôle SonarQube</label>
          <div class="sq-role-group">
            <input type="radio" id="sq-role-user" name="role" value="user" class="sq-role-radio" checked />
            <label for="sq-role-user" class="sq-role-label">Utilisateur</label>
            <input type="radio" id="sq-role-admin" name="role" value="admin" class="sq-role-radio" />
            <label for="sq-role-admin" class="sq-role-label">Administrateur</label>
            <input type="radio" id="sq-role-audit" name="role" value="auditor" class="sq-role-radio" />
            <label for="sq-role-audit" class="sq-role-label">Auditeur</label>
          </div>
        </div>
        <button type="submit" class="sq-btn">Créer mon compte</button>
        <button type="button" class="sq-btn sq-btn-secondary" onclick="sqSwitch('login')">Déjà inscrit ? Connexion</button>
      </form>
    </div>
  </div>
  <script>
    // --- Animation bulles interactives ---
    const canvas = document.getElementById('bubbles-bg');
    const ctx = canvas.getContext('2d');
    let bubbles = [];
    let particles = [];
    function resizeCanvas() {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    }
    window.addEventListener('resize', resizeCanvas);
    resizeCanvas();

    function randomColor() {
      const colors = [
        'rgba(0,180,239,0.18)',
        'rgba(0,230,195,0.16)',
        'rgba(0,180,239,0.13)',
        'rgba(0,180,239,0.22)'
      ];
      return colors[Math.floor(Math.random() * colors.length)];
    }

    function createBubble() {
      const r = 24 + Math.random() * 36;
      const x = Math.random() * (canvas.width - 2*r) + r;
      const y = Math.random() * (canvas.height - 2*r) + r;
      const dx = (Math.random() - 0.5) * 0.7;
      const dy = (Math.random() - 0.5) * 0.7;
      bubbles.push({
        x, y, r,
        dx, dy,
        color: randomColor(),
        alive: true
      });
    }

    for(let i=0;i<18;i++) createBubble();

    function drawBubbles() {
      for(const b of bubbles) {
        if(!b.alive) continue;
        ctx.beginPath();
        ctx.arc(b.x, b.y, b.r, 0, 2*Math.PI);
        ctx.fillStyle = b.color;
        ctx.shadowColor = '#00b4ef';
        ctx.shadowBlur = 12;
        ctx.fill();
        ctx.shadowBlur = 0;
      }
    }

    function updateBubbles() {
      for(const b of bubbles) {
        if(!b.alive) continue;
        b.x += b.dx;
        b.y += b.dy;
        // Bounce
        if(b.x-b.r<0 || b.x+b.r>canvas.width) b.dx *= -1;
        if(b.y-b.r<0 || b.y+b.r>canvas.height) b.dy *= -1;
      }
    }

    // Particles for explosion
    function createExplosion(x, y, color) {
      for(let i=0;i<18;i++) {
        const angle = (Math.PI*2) * (i/18);
        const speed = 2 + Math.random()*2;
        particles.push({
          x, y,
          dx: Math.cos(angle)*speed,
          dy: Math.sin(angle)*speed,
          r: 3 + Math.random()*2,
          alpha: 1,
          color
        });
      }
    }
    function drawParticles() {
      for(const p of particles) {
        ctx.save();
        ctx.globalAlpha = p.alpha;
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, 2*Math.PI);
        ctx.fillStyle = p.color.replace(/[\d\.]+\)$/,'0.7)');
        ctx.fill();
        ctx.restore();
      }
    }
    function updateParticles() {
      for(const p of particles) {
        p.x += p.dx;
        p.y += p.dy;
        p.alpha -= 0.025;
      }
      particles = particles.filter(p=>p.alpha>0);
    }

    function animate() {
      ctx.clearRect(0,0,canvas.width,canvas.height);
      drawBubbles();
      drawParticles();
      updateBubbles();
      updateParticles();
      requestAnimationFrame(animate);
    }
    animate();

    // Explosion on click
    canvas.addEventListener('click', function(e){
      const rect = canvas.getBoundingClientRect();
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;
      for(const b of bubbles) {
        if(!b.alive) continue;
        const dist = Math.hypot(mx-b.x, my-b.y);
        if(dist < b.r) {
          b.alive = false;
          createExplosion(b.x, b.y, b.color);
          setTimeout(()=>createBubble(), 800);
          break;
        }
      }
    });

    // --- Ton JS existant (inchangé) ---
    function sqSwitch(mode) {
      const loginForm = document.getElementById('sq-login-form');
      const registerForm = document.getElementById('sq-register-form');
      const resetForm = document.getElementById('sq-reset-form');
      const btns = document.querySelectorAll('.sq-switch-btn');
      const title = document.getElementById('sq-form-title');
      btns.forEach(b => b.classList.remove('active'));
      resetForm.classList.remove('active');
      if (mode === 'login') {
        loginForm.classList.add('active');
        registerForm.classList.remove('active');
        btns[0].classList.add('active');
        title.textContent = "Connectez-vous à SonarQube";
      } else {
        loginForm.classList.remove('active');
        registerForm.classList.add('active');
        btns[1].classList.add('active');
        title.textContent = "Créer un compte SonarQube";
      }
    }
    function showResetForm() {
      document.getElementById('sq-login-form').classList.remove('active');
      document.getElementById('sq-reset-form').classList.add('active');
      document.getElementById('sq-form-title').textContent = "Réinitialiser le mot de passe";
    }
    function hideResetForm() {
      document.getElementById('sq-reset-form').classList.remove('active');
      document.getElementById('sq-login-form').classList.add('active');
      document.getElementById('sq-form-title').textContent = "Connectez-vous à SonarQube";
    }
    // Password match feedback
    document.addEventListener('DOMContentLoaded', function() {
      const regForm = document.getElementById('sq-register-form');
      const pass = document.getElementById('sq-newpass');
      const confirm = document.getElementById('sq-confirmpass');
      const feedback = document.getElementById('sq-passmatch');
      function checkPass() {
        if (!confirm.value) {
          feedback.textContent = '';
          feedback.classList.remove('show');
          return;
        }
        if (pass.value === confirm.value && pass.value.length >= 8) {
          feedback.textContent = '✔ Les mots de passe correspondent';
          feedback.style.color = 'var(--sonar-accent)';
          feedback.classList.add('show');
        } else if (pass.value === confirm.value && pass.value.length < 8) {
          feedback.textContent = '⚠ Minimum 8 caractères requis';
          feedback.style.color = '#e94e77';
          feedback.classList.add('show');
        } else {
          feedback.textContent = '✗ Les mots de passe ne correspondent pas';
          feedback.style.color = '#e94e77';
          feedback.classList.add('show');
        }
      }
      pass.addEventListener('input', checkPass);
      confirm.addEventListener('input', checkPass);
      regForm.addEventListener('submit', function(e) {
        if (pass.value !== confirm.value || pass.value.length < 8) {
          e.preventDefault();
          feedback.classList.add('show');
          if (pass.value !== confirm.value) {
            feedback.textContent = '✗ Les mots de passe ne correspondent pas';
          } else {
            feedback.textContent = '⚠ Minimum 8 caractères requis';
          }
          feedback.style.color = '#e94e77';
        }
      });
    });
  </script>
</#if>
</@layout.registrationLayout>
