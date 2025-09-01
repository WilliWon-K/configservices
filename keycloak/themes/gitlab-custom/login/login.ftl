<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayWide=true; section>
  <#if section = "header">
    <!-- Header vide pour éviter le titre automatique -->
  <#elseif section = "form">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        :root {
            --talan-blue: #4285f4;
            --talan-orange: #ff6b35;
            --talan-green: #34a853;
            --talan-purple: #9c27b0;
            --talan-red: #ea4335;
            --talan-yellow: #fbbc04;
            --bg-primary: #f8fafc;
            --bg-card: #ffffff;
            --surface: rgba(255, 255, 255, 0.9);
            --border: #e2e8f0;
            --border-focus: #6366f1;
            --text-primary: #1e293b;
            --text-secondary: #64748b;
            --text-muted: #94a3b8;
            --primary: #6366f1;
            --primary-hover: #5b5fdb;
            --input-bg: #f8fafc;
            --input-focus: #ffffff;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { height: 100%; width: 100%; }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif !important;
            background: var(--bg-primary) !important;
            min-height: 100vh !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            padding: 20px !important;
            margin: 0 !important;
        }
        .login-pf-page {
            width: 100vw !important;
            height: 100vh !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            padding: 20px !important;
        }
        .card-pf {
            background: var(--bg-card) !important;
            border-radius: 16px !important;
            box-shadow: var(--shadow-lg) !important;
            border: 1px solid var(--border) !important;
            width: 100% !important;
            max-width: 420px !important;
            padding: 48px 40px !important;
            position: relative !important;
            overflow: hidden !important;
        }
        .card-pf::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 12px;
            background: linear-gradient(135deg,
                #5580b9 0%,
                #1d662e 25%,
                #8e9423 50%,
                #6c367e 75%,
                #e14480 100%
            );
        }
        .gitlab-logo {
            text-align: center;
            margin-bottom: 32px;
        }
        .gitlab-logo h1 {
            font-size: 36px !important;
            font-weight: 700 !important;
            margin: 0 !important;
            display: inline-flex !important;
            letter-spacing: -0.02em !important;
        }
        .logo-letter:nth-child(1) { color: var(--talan-blue); }
        .logo-letter:nth-child(2) { color: var(--talan-orange); }
        .logo-letter:nth-child(3) { color: var(--talan-green); }
        .logo-letter:nth-child(4) { color: var(--talan-purple); }
        .logo-letter:nth-child(5) { color: var(--talan-red); }
        .logo-letter:nth-child(6) { color: var(--talan-yellow); }
        .gitlab-logo .logo-letter { color: #1e293b !important; }
        .talan-logo {
            display: inline-flex;
            align-items: center;
            margin-left: 8px;
        }
        .talan-text {
            font-weight: 700;
            color: #1e293b;
            letter-spacing: 0.04em;
            font-size: 28px;
            margin-right: 4px;
        }
        .custom-header {
          display: flex;
          flex-direction: column;
          align-items: center;
          margin-bottom: 32px;
        margin-top: 0;
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
        }
        .mode-switcher {
            display: flex;
            background: var(--input-bg);
            border-radius: 12px;
            padding: 4px;
            margin-bottom: 32px;
            border: 1px solid var(--border);
        }
        .mode-btn {
            flex: 1;
            padding: 12px 16px;
            background: transparent;
            border: none;
            border-radius: 8px;
            color: var(--text-secondary);
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .mode-btn.active {
            background: var(--primary);
            color: white;
            font-weight: 600;
            box-shadow: var(--shadow-sm);
        }
        .mode-btn:hover:not(.active) {
            color: var(--text-primary);
            background: rgba(99, 102, 241, 0.05);
        }
        .subtitle {
            color: var(--text-primary);
            font-size: 16px;
            font-weight: 500;
            text-align: center;
            margin-bottom: 32px;
        }
        .auth-form { display: none; }
        .auth-form.active {
            display: block;
            animation: fadeIn 0.3s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .form-group { margin-bottom: 24px !important; }
        .form-label {
            display: block;
            margin-bottom: 8px;
            color: var(--text-primary);
            font-size: 14px;
            font-weight: 500;
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
        }
        .form-control::placeholder { color: var(--text-muted) !important; }
        .form-control:focus {
            outline: none !important;
            border-color: var(--border-focus) !important;
            background: var(--input-focus) !important;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1) !important;
        }
        .form-control.success { border-color: var(--talan-green) !important; }
        .form-control.error { border-color: var(--talan-red) !important; }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .role-selector {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
            margin-top: 8px;
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
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s ease;
            cursor: pointer;
        }
        .role-option input[type="radio"]:checked + .role-label {
            background: var(--primary);
            border-color: var(--primary);
            color: white;
        }
        .role-label:hover {
            background: rgba(99, 102, 241, 0.05);
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
        .password-feedback.success { color: var(--talan-green); }
        .password-feedback.error { color: var(--talan-red); }
        #kc-form-options {
            display: flex !important;
            justify-content: space-between !important;
            align-items: center !important;
            margin: 24px 0 !important;
        }
        #kc-form-options label {
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
            cursor: pointer !important;
            color: var(--text-secondary) !important;
            font-size: 14px !important;
            font-weight: 400 !important;
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
        #kc-form-reset-psw a {
            color: var(--text-muted) !important;
            text-decoration: none !important;
            font-size: 14px !important;
            transition: color 0.2s !important;
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
            box-shadow: var(--shadow-sm) !important;
        }
        .btn:hover {
            background: var(--primary-hover) !important;
            transform: translateY(-1px) !important;
            box-shadow: var(--shadow) !important;
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
        @media (max-width: 768px) {
            .card-pf {
                padding: 32px 24px !important;
                margin: 16px !important;
                max-width: calc(100vw - 32px) !important;
            }
            .form-row { grid-template-columns: 1fr; }
            .role-selector { grid-template-columns: 1fr; }
        }
        @media (max-width: 480px) {
            .login-pf-page { padding: 16px !important; }
            .card-pf { padding: 24px 20px !important; }
            .gitlab-logo h1 { font-size: 32px !important; }
        }
    </style>
    <div class="login-pf-page">
      <div class="card-pf">
        <!-- Logo GitLab avec couleurs Talan -->
        <div class="custom-header">
          <img src="https://www.semaine-nsi.fr/app/uploads/2024/11/TALAN_logo.jpg" alt="Talan" class="talan-img-large" />
          <div class="custom-title">Gitlab Sécurité CI/CD</div>
        </div>
        <!-- Mode Switcher -->
        <div class="mode-switcher">
          <button type="button" class="mode-btn active" onclick="switchMode('login')">Connexion</button>
          <button type="button" class="mode-btn" onclick="switchMode('register')">Inscription</button>
        </div>
        <!-- Login Form -->
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
        <!-- Mot de passe oublié Form -->
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
        <!-- Register Form -->
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
            <div class="form-group">
              <label class="form-label">Rôle sur GitLab *</label>
              <div class="role-selector">
                <div class="role-option">
                  <input type="radio" id="developer" name="role" value="developer" checked />
                  <label for="developer" class="role-label">Developer</label>
                </div>
                <div class="role-option">
                  <input type="radio" id="maintainer" name="role" value="maintainer" />
                  <label for="maintainer" class="role-label">Maintainer</label>
                </div>
                <div class="role-option">
                  <input type="radio" id="owner" name="role" value="owner" />
                  <label for="owner" class="role-label">Owner</label>
                </div>
                <div class="role-option">
                  <input type="radio" id="reporter" name="role" value="reporter" />
                  <label for="reporter" class="role-label">Reporter</label>
                </div>
              </div>
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
    <script>
        // Mode switching
        function switchMode(mode) {
            const loginForm = document.getElementById('login-form');
            const registerForm = document.getElementById('register-form');
            const resetForm = document.getElementById('reset-form');
            const buttons = document.querySelectorAll('.mode-btn');
            const subtitle = document.getElementById('page-subtitle');
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
                buttons[1].classList.add('active');            }
        }
        function showResetForm() {
            document.getElementById('login-form').classList.remove('active');
            document.getElementById('reset-form').classList.add('active');
            document.getElementById('page-subtitle').textContent = "Réinitialisez votre mot de passe";
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
