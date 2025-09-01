<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayWide=true; section>
  <#if section = "header">
    <!-- Header vide pour éviter le titre automatique -->
  <#elseif section = "form">
    <style>
      @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
      :root {
          --harbor-blue: #1b314b;
          --harbor-sea: #3a6ea5;
          --harbor-sky: #7ec4e4;
          --bg-card: #ffffff;
          --border: #e2e8f0;
          --border-focus: #3a6ea5;
          --text-primary: #1b314b;
          --primary: #3a6ea5;
          --primary-hover: #1b314b;
          --input-bg: #f6faff;
          --input-focus: #ffffff;
          --shadow-lg: 0 10px 15px -3px rgba(58, 110, 165, 0.10);
      }
      html, body { height: 100%; width: 100%; }
      body {
          font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif !important;
          min-height: 100vh !important;
          margin: 0 !important;
          background: url('https://s2.best-wallpaper.net/wallpaper/2880x1800/1706/Port-container-hoist_2880x1800.jpg') center center/cover no-repeat !important;
          position: relative;
      }
      .overlay-bg {
          position: fixed;
          inset: 0;
          background: rgba(27,49,75,0.45);
          z-index: 0;
          pointer-events: none;
      }
      .main-layout-harbor {
          min-height: 100vh;
          width: 100vw;
          display: flex;
          align-items: center;
          justify-content: center;
          position: relative;
          z-index: 1;
      }
      .harbor-content {
          display: flex;
          align-items: center;
          justify-content: flex-start;
          min-height: 100vh;
          width: 100vw;
          box-sizing: border-box;
          padding-left: 8vw;
      }
      .card-pf {
          background: var(--bg-card);
          border-radius: 32px;
          box-shadow: var(--shadow-lg);
          border: 1px solid var(--border);
          width: 100%;
          max-width: 420px;
          padding: 48px 40px 32px 40px;
          position: relative;
          z-index: 2;
          display: flex;
          flex-direction: column;
          align-items: center;
          min-width: 320px;
          overflow: hidden; /* Pour la bande arrondie */
      }
      .card-pf::before {
          content: '';
          position: absolute;
          top: 0;
          left: 0;
          right: 0;
          height: 14px;
          background: linear-gradient(90deg, #1b314b 0%, #3a6ea5 60%, #7ec4e4 100%);
          border-radius: 32px 32px 0 0;
          z-index: 3;
      }
      .custom-header {
          display: flex;
          flex-direction: column;
          align-items: center;
          margin-bottom: 32px;
          margin-top: 0;
          width: 100%;
      }
      .talan-img-large {
          max-width: 320px;
          width: 100%;
          height: auto;
          margin-bottom: 10px;
          object-fit: contain;
          margin-top: -24px;
      }
      .custom-title {
          font-size: 2rem;
          font-weight: 700;
          color: var(--text-primary);
          letter-spacing: -0.01em;
          text-align: center;
          width: 100%;
          margin-bottom: 0.5em;
      }
      .mode-switcher {
          display: flex;
          background: var(--input-bg);
          border-radius: 12px;
          padding: 4px;
          margin-bottom: 32px;
          border: 1px solid var(--border);
          width: 100%;
          justify-content: center;
      }
      .mode-btn {
          flex: 1;
          padding: 12px 16px;
          background: transparent;
          border: none;
          border-radius: 8px;
          color: var(--primary);
          font-size: 14px;
          font-weight: 500;
          cursor: pointer;
          transition: all 0.2s ease;
          text-align: center;
      }
      .mode-btn.active {
          background: var(--primary);
          color: white;
          font-weight: 600;
          box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05);
      }
      .mode-btn:hover:not(.active) {
          color: var(--text-primary);
          background: rgba(58, 110, 165, 0.08);
      }
      .subtitle {
          color: var(--text-primary);
          font-size: 16px;
          font-weight: 500;
          text-align: center;
          margin-bottom: 32px;
          width: 100%;
      }
      .auth-form { display: none; width: 100%; }
      .auth-form.active {
          display: block;
          animation: fadeIn 0.3s ease-out;
      }
      @keyframes fadeIn {
          from { opacity: 0; transform: translateY(8px); }
          to { opacity: 1; transform: translateY(0); }
      }
      .form-group { margin-bottom: 24px !important; width: 100%; }
      .form-label {
          display: block;
          margin-bottom: 8px;
          color: var(--text-primary);
          font-size: 14px;
          font-weight: 500;
          text-align: left;
      }
      .form-control {
          width: 100% !important;
          padding: 16px !important;
          background: var(--input-bg) !important;
          border: 1px solid var(--border) !important;
          border-radius: 12px !important;
          font-size: 16px !important;
          color: var(--text-primary) !important;
          transition: all 0.2s ease !important;
          font-family: inherit !important;
          box-sizing: border-box;
      }
      .form-control::placeholder { color: #7ec4e4 !important; }
      .form-control:focus {
          outline: none !important;
          border-color: var(--border-focus) !important;
          background: var(--input-focus) !important;
          box-shadow: 0 0 0 3px rgba(58, 110, 165, 0.10) !important;
      }
      .form-control.success { border-color: var(--harbor-sea) !important; }
      .form-control.error { border-color: #f9a03f !important; }
      .form-row {
          display: flex;
          flex-direction: row;
          gap: 16px;
          width: 100%;
          margin-bottom: 24px !important; /* Uniformise l'espacement */
      }
      .form-row .form-group {
          flex: 1 1 0;
          margin-bottom: 0 !important;
      }
      .role-selector {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 12px;
          margin-top: 8px;
          width: 100%;
      }
      @media (max-width: 900px) {
        .role-selector {
          grid-template-columns: repeat(2, 1fr);
        }
      }
      @media (max-width: 700px) {
          .form-row {
              flex-direction: column;
              gap: 0;
              margin-bottom: 0 !important;
          }
          .form-row .form-group {
              margin-bottom: 24px !important;
          }
          .role-selector {
              grid-template-columns: repeat(2, 1fr);
          }
      }
      .role-option { position: relative; }
      .role-option input[type="radio"] {
          position: absolute;
          opacity: 0;
          width: 100%;
          height: 100%;
          cursor: pointer;
      }
      .role-label {
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 12px;
          background: var(--input-bg);
          border: 1px solid var(--border);
          border-radius: 8px;
          color: var(--primary);
          font-size: 13px;
          font-weight: 500;
          transition: all 0.2s ease;
          cursor: pointer;
          width: 100%;
          text-align: center;
      }
      .role-option input[type="radio"]:checked + .role-label {
          background: var(--primary);
          border-color: var(--primary);
          color: white;
      }
      .role-label:hover {
          background: rgba(58, 110, 165, 0.08);
          border-color: var(--border-focus);
          color: var(--text-primary);
      }
      .password-feedback {
          margin-top: 8px;
          font-size: 13px;
          font-weight: 500;
          opacity: 0;
          transition: all 0.2s ease;
          display: flex;
          align-items: center;
          gap: 6px;
      }
      .password-feedback.show { opacity: 1; }
      .password-feedback.success { color: var(--harbor-sea); }
      .password-feedback.error { color: #f9a03f; }
      #kc-form-options {
          display: flex !important;
          justify-content: center !important;
          align-items: center !important;
          margin: 24px 0 !important;
          gap: 16px;
          width: 100%;
      }
      #kc-form-options label {
          display: flex !important;
          align-items: center !important;
          gap: 8px !important;
          cursor: pointer !important;
          color: var(--primary) !important;
          font-size: 14px !important;
          font-weight: 400 !important;
          margin-bottom: 0;
      }
      .custom-checkbox {
          width: 18px !important;
          height: 18px !important;
          border: 2px solid var(--border) !important;
          border-radius: 4px !important;
          background: var(--input-bg) !important;
          position: relative !important;
          transition: all 0.2s ease !important;
      }
      input[type="checkbox"]:checked + .custom-checkbox {
          background: var(--primary) !important;
          border-color: var(--primary) !important;
      }
      input[type="checkbox"]:checked + .custom-checkbox::after {
          content: '✓';
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          color: white;
          font-size: 12px;
          font-weight: bold;
      }
      #kc-form-reset-psw {
          margin-left: 8px;
      }
      #kc-form-reset-psw a {
          color: #7ec4e4 !important;
          text-decoration: none !important;
          font-size: 14px !important;
          transition: color 0.2s !important;
          text-align: center;
          display: block;
      }
      #kc-form-reset-psw a:hover { color: var(--primary) !important; }
      .btn {
          width: 100% !important;
          padding: 16px !important;
          background: var(--primary) !important;
          border: none !important;
          border-radius: 12px !important;
          color: white !important;
          font-size: 16px !important;
          font-weight: 600 !important;
          cursor: pointer !important;
          transition: all 0.2s ease !important;
          box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05) !important;
          margin: 0 auto;
          display: block;
          text-align: center;
      }
      .btn:hover {
          background: var(--primary-hover) !important;
          transform: translateY(-1px) !important;
          box-shadow: 0 4px 6px -1px rgba(0,0,0,0.08) !important;
      }
      .btn:active { transform: translateY(0) !important; }
      .btn-secondary {
          background: transparent !important;
          color: var(--text-primary) !important;
          border: 1px solid var(--border) !important;
          box-shadow: none !important;
          margin-top: 12px !important;
      }
      .btn-secondary:hover {
          background: var(--input-bg) !important;
          border-color: var(--border-focus) !important;
      }
      #kc-form-buttons {
          width: 100%;
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 12px;
      }
      @media (max-width: 700px) {
          .main-layout-harbor, .harbor-content {
              justify-content: center;
              align-items: flex-start;
          }
          .card-pf {
              width: 98vw;
              max-width: 98vw;
              border-radius: 18px;
              padding: 18px 6px;
          }
      }
      @media (max-width: 900px) {
          .harbor-content {
              padding-left: 2vw;
          }
      }
      @media (max-width: 700px) {
          .harbor-content {
              justify-content: center;
              align-items: flex-start;
              padding-left: 0;
          }
      }
    </style>
    <div class="overlay-bg"></div>
    <div class="main-layout-harbor">
      <div class="harbor-content">
        <div class="card-pf">
          <div class="custom-header">
            <img src="https://www.semaine-nsi.fr/app/uploads/2024/11/TALAN_logo.jpg" alt="Talan" class="talan-img-large" />
            <div class="custom-title">Harbor</div>
          </div>
          <div class="mode-switcher">
            <button type="button" class="mode-btn active" onclick="switchMode('login')">Connexion</button>
            <button type="button" class="mode-btn" onclick="switchMode('register')">Inscription</button>
          </div>
          <div id="login-form" class="auth-form active">
            <form id="kc-form-login" onsubmit="login.disabled = true; login.value = 'Connexion...'; return true;" action="${url.loginAction}" method="post">
              <div class="form-group">
                <label class="form-label" for="username">Nom d'utilisateur ou email</label>
                <input tabindex="1"
                       id="username"
                       class="form-control"
                       name="username"
                       value="${(login.username!'')}"
                       type="text"
                       placeholder="votre.nom@talan.com"
                       autofocus />
              </div>
              <div class="form-group">
                <label class="form-label" for="password">Mot de passe</label>
                <input tabindex="2"
                       id="password"
                       class="form-control"
                       name="password"
                       type="password"
                       placeholder="••••••••" />
              </div>
              <div id="kc-form-options">
                <#if realm.rememberMe && !usernameEditDisabled??>
                  <label for="rememberMe">
                    <input type="checkbox"
                           id="rememberMe"
                           name="rememberMe"
                           <#if login.rememberMe??>checked</#if>
                           style="display: none;" />
                    <span class="custom-checkbox"></span>
                    <span>Se souvenir de moi</span>
                  </label>
                </#if>
                <div id="kc-form-reset-psw">
                  <a href="#" onclick="showResetForm();return false;">Mot de passe oublié ?</a>
                </div>
              </div>
              <div id="kc-form-buttons">
                <input type="hidden" id="id-hidden-input" name="credentialId" />
                <input tabindex="4"
                       class="btn"
                       name="login"
                       id="kc-login"
                       type="submit"
                       value="Se connecter" />
              </div>
            </form>
          </div>
          <div id="reset-form" class="auth-form">
            <form id="kc-form-reset" autocomplete="off">
              <div class="form-group">
                <label class="form-label" for="resetEmail">Votre email professionnel</label>
                <input id="resetEmail" class="form-control" name="resetEmail" type="email" placeholder="jean.dupont@talan.com" required />
              </div>
              <div id="kc-form-buttons">
                <button type="submit" class="btn">Envoyer le lien de réinitialisation</button>
                <button type="button" class="btn btn-secondary" onclick="showLoginForm()">Annuler</button>
              </div>
            </form>
          </div>
          <div id="register-form" class="auth-form">
            <form id="kc-form-register" method="post">
              <div class="form-row">
                <div class="form-group">
                  <label class="form-label" for="firstName">Prénom *</label>
                  <input id="firstName"
                         class="form-control"
                         name="firstName"
                         type="text"
                         placeholder="Jean"
                         required />
                </div>
                <div class="form-group">
                  <label class="form-label" for="lastName">Nom *</label>
                  <input id="lastName"
                         class="form-control"
                         name="lastName"
                         type="text"
                         placeholder="Dupont"
                         required />
                </div>
              </div>
              <div class="form-group">
                <label class="form-label" for="email">Email professionnel *</label>
                <input id="email"
                       class="form-control"
                       name="email"
                       type="email"
                       placeholder="jean.dupont@talan.com"
                       required />
              </div>
              <div class="form-group">
                <label class="form-label" for="newPassword">Mot de passe *</label>
                <input id="newPassword"
                       class="form-control"
                       name="password"
                       type="password"
                       placeholder="••••••••"
                       required />
              </div>
              <div class="form-group">
                <label class="form-label" for="confirmPassword">Confirmer le mot de passe *</label>
                <input id="confirmPassword"
                       class="form-control"
                       name="confirmPassword"
                       type="password"
                       placeholder="••••••••"
                       required />
                <div id="password-match" class="password-feedback"></div>
              </div>
              <div id="kc-form-buttons">
                <button type="submit" class="btn">Créer mon compte</button>
                <button type="button" class="btn btn-secondary" onclick="switchMode('login')" style="margin-top: 12px;">
                  Déjà un compte ? Se connecter
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <script>
        // Mode switching
        function switchMode(mode) {
            const loginForm = document.getElementById('login-form');
            const registerForm = document.getElementById('register-form');
            const resetForm = document.getElementById('reset-form');
            const buttons = document.querySelectorAll('.mode-btn');
            buttons.forEach(btn => btn.classList.remove('active'));
            if (mode === 'login') {
                loginForm.classList.add('active');
                registerForm.classList.remove('active');
                resetForm.classList.remove('active');
                buttons[0].classList.add('active');
            } else {
                loginForm.classList.remove('active');
                registerForm.classList.add('active');
                resetForm.classList.remove('active');
                buttons[1].classList.add('active');
            }
        }
        function showResetForm() {
            document.getElementById('login-form').classList.remove('active');
            document.getElementById('reset-form').classList.add('active');
        }
        function showLoginForm() {
            document.getElementById('reset-form').classList.remove('active');
            document.getElementById('login-form').classList.add('active');
        }
        document.getElementById('kc-form-reset')?.addEventListener('submit', function(e) {
            e.preventDefault();
            const email = document.getElementById('resetEmail').value.trim();
            if (!email) {
                alert('Veuillez saisir votre email.');
                return;
            }
            alert('📧 Un lien de réinitialisation a été envoyé à ' + email);
            showLoginForm();
        });
        document.addEventListener('DOMContentLoaded', function() {
            // Animation d'entrée pour les champs
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach((input, index) => {
                input.style.opacity = '0';
                input.style.transform = 'translateY(10px)';
                setTimeout(() => {
                    input.style.transition = 'all 0.4s ease';
                    input.style.opacity = '1';
                    input.style.transform = 'translateY(0)';
                }, 100 + (index * 30));
            });
            // Validation des mots de passe
            const registerForm = document.getElementById('kc-form-register');
            if (registerForm) {
                const newPassword = document.getElementById('newPassword');
                const confirmPassword = document.getElementById('confirmPassword');
                const passwordFeedback = document.getElementById('password-match');
                function validatePasswords() {
                    const password = newPassword.value;
                    const confirm = confirmPassword.value;
                    if (confirm === '') {
                        passwordFeedback.classList.remove('show');
                        confirmPassword.classList.remove('success', 'error');
                        return null;
                    }
                    if (password === confirm && password.length >= 8) {
                        passwordFeedback.innerHTML = '<span>✓</span> Les mots de passe correspondent';
                        passwordFeedback.className = 'password-feedback show success';
                        confirmPassword.classList.remove('error');
                        confirmPassword.classList.add('success');
                        return true;
                    } else if (password === confirm && password.length < 8) {
                        passwordFeedback.innerHTML = '<span>⚠</span> Minimum 8 caractères requis';
                        passwordFeedback.className = 'password-feedback show error';
                        confirmPassword.classList.remove('success');
                        confirmPassword.classList.add('error');
                        return false;
                    } else {
                        passwordFeedback.innerHTML = '<span>✗</span> Les mots de passe ne correspondent pas';
                        passwordFeedback.className = 'password-feedback show error';
                        confirmPassword.classList.remove('success');
                        confirmPassword.classList.add('error');
                        return false;
                    }
                }
                newPassword.addEventListener('input', validatePasswords);
                confirmPassword.addEventListener('input', validatePasswords);
                registerForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    const firstName = document.getElementById('firstName').value.trim();
                    const lastName = document.getElementById('lastName').value.trim();
                    const email = document.getElementById('email').value.trim();
                    const password = document.getElementById('newPassword').value;
                    const confirmPass = document.getElementById('confirmPassword').value;
                    const role = document.querySelector('input[name="role"]:checked').value;
                    if (!firstName || !lastName || !email || !password || !confirmPass || !role) {
                        alert('⚠️ Veuillez remplir tous les champs obligatoires');
                        return;
                    }
                    if (password !== confirmPass) {
                        alert('❌ Les mots de passe ne correspondent pas');
                        return;
                    }
                    if (password.length < 8) {
                        alert('⚠️ Le mot de passe doit contenir au moins 8 caractères');
                        return;
                    }
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    if (!emailRegex.test(email)) {
                        alert('⚠️ Veuillez saisir un email valide');
                        return;
                    }
                    const submitBtn = this.querySelector('button[type="submit"]');
                    submitBtn.textContent = 'Création en cours...';
                    submitBtn.disabled = true;
                    setTimeout(() => {
                        alert('✅ Compte créé avec succès !');
                        switchMode('login');
                        this.reset();
                        passwordFeedback.classList.remove('show');
                        submitBtn.textContent = 'Créer mon compte';
                        submitBtn.disabled = false;
                    }, 2000);
                });
            }
        });
    </script>
  </#if>
</@layout.registrationLayout>
