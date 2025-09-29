<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm') displayInfo=social.displayInfo displayWide=true; section>
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
                text-decoration: none;
                display: flex;
                align-items: center;
                justify-content: center;
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
            .form-control.error { 
                border-color: var(--talan-red) !important;
                background: #fef2f2 !important;
            }
            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
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
            #kc-form-buttons {
                width: 100% !important;
                display: flex !important;
                flex-direction: column !important;
                align-items: center !important;
                gap: 12px !important;
            }
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
                text-decoration: none !important;
                display: inline-block !important;
                text-align: center !important;
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
            .alert-error {
                background: #fef2f2;
                border: 1px solid #fecaca;
                color: var(--talan-red);
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 24px;
                font-size: 14px;
            }
            @media (max-width: 768px) {
                .card-pf {
                    padding: 32px 24px !important;
                    margin: 16px !important;
                    max-width: calc(100vw - 32px) !important;
                }
                .form-row { grid-template-columns: 1fr; }
            }
            @media (max-width: 480px) {
                .login-pf-page { padding: 16px !important; }
                .card-pf { padding: 24px 20px !important; }
                .custom-title { font-size: 1.75rem !important; }
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
                    <a href="${url.loginUrl}" class="mode-btn">Connexion</a>
                    <button type="button" class="mode-btn active">Inscription</button>
                </div>

                <#if messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm')>
                    <div class="alert-error">
                        <#list messagesPerField.get('firstName') as error>
                            ${error}<br>
                        </#list>
                        <#list messagesPerField.get('lastName') as error>
                            ${error}<br>
                        </#list>
                        <#list messagesPerField.get('email') as error>
                            ${error}<br>
                        </#list>
                        <#list messagesPerField.get('username') as error>
                            ${error}<br>
                        </#list>
                        <#list messagesPerField.get('password') as error>
                            ${error}<br>
                        </#list>
                        <#list messagesPerField.get('password-confirm') as error>
                            ${error}<br>
                        </#list>
                    </div>
                </#if>

                <!-- Register Form -->
                <div id="register-form" class="auth-form active">
                    <form id="kc-form-register" action="${url.registrationAction}" method="post">
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="firstName">${msg("firstName")} *</label>
                                <input type="text" id="firstName" class="form-control" name="firstName" 
                                       value="${(register.formData.firstName!'')}" placeholder="Jean" 
                                       aria-invalid="<#if messagesPerField.existsError('firstName')>true</#if>" required />
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="lastName">${msg("lastName")} *</label>
                                <input type="text" id="lastName" class="form-control" name="lastName" 
                                       value="${(register.formData.lastName!'')}" placeholder="Dupont" 
                                       aria-invalid="<#if messagesPerField.existsError('lastName')>true</#if>" required />
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label" for="email">${msg("email")} *</label>
                            <input type="email" id="email" class="form-control" name="email" 
                                   value="${(register.formData.email!'')}" placeholder="jean.dupont@talan.com" 
                                   aria-invalid="<#if messagesPerField.existsError('email')>true</#if>" required />
                        </div>
                        
                        <#if !realm.registrationEmailAsUsername>
                            <div class="form-group">
                                <label class="form-label" for="username">${msg("username")} *</label>
                                <input type="text" id="username" class="form-control" name="username" 
                                       value="${(register.formData.username!'')}" placeholder="jean.dupont" 
                                       aria-invalid="<#if messagesPerField.existsError('username')>true</#if>" required />
                            </div>
                        </#if>
                        
                        <#if passwordRequired??>
                            <div class="form-group">
                                <label class="form-label" for="password">${msg("password")} *</label>
                                <input type="password" id="password" class="form-control" name="password" 
                                       placeholder="••••••••" 
                                       aria-invalid="<#if messagesPerField.existsError('password')>true</#if>" required />
                            </div>
                            
                            <div class="form-group">
                                <label class="form-label" for="password-confirm">${msg("passwordConfirm")} *</label>
                                <input type="password" id="password-confirm" class="form-control" name="password-confirm" 
                                       placeholder="••••••••" 
                                       aria-invalid="<#if messagesPerField.existsError('password-confirm')>true</#if>" required />
                                <div id="password-match" class="password-feedback"></div>
                            </div>
                        </#if>
                        
                        <#if recaptchaRequired??>
                            <div class="form-group">
                                <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
                            </div>
                        </#if>
                        
                        <div id="kc-form-buttons">
                            <input class="btn" type="submit" value="${msg("doRegister")}"/>
                            <a href="${url.loginUrl}" class="btn btn-secondary">${msg("backToLogin")}</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script>
            // Validation des mots de passe côté client
            document.addEventListener('DOMContentLoaded', function() {
                const newPassword = document.getElementById('password');
                const confirmPassword = document.getElementById('password-confirm');
                const feedback = document.getElementById('password-match');
                
                if (newPassword && confirmPassword && feedback) {
                    function validatePasswords() {
                        const password = newPassword.value;
                        const confirm = confirmPassword.value;
                        
                        if (confirm === '') {
                            feedback.classList.remove('show');
                            confirmPassword.classList.remove('success', 'error');
                            return null;
                        }
                        
                        if (password === confirm && password.length >= 8) {
                            feedback.innerHTML = '<span>✓</span> Les mots de passe correspondent';
                            feedback.className = 'password-feedback show success';
                            confirmPassword.classList.remove('error');
                            confirmPassword.classList.add('success');
                            return true;
                        } else if (password === confirm && password.length < 8) {
                            feedback.innerHTML = '<span>⚠</span> Minimum 8 caractères requis';
                            feedback.className = 'password-feedback show error';
                            confirmPassword.classList.remove('success');
                            confirmPassword.classList.add('error');
                            return false;
                        } else {
                            feedback.innerHTML = '<span>✗</span> Les mots de passe ne correspondent pas';
                            feedback.className = 'password-feedback show error';
                            confirmPassword.classList.remove('success');
                            confirmPassword.classList.add('error');
                            return false;
                        }
                    }
                    
                    newPassword.addEventListener('input', validatePasswords);
                    confirmPassword.addEventListener('input', validatePasswords);
                }
                
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
                
                // Marquer les champs avec erreurs
                <#if messagesPerField.existsError('firstName')>
                    document.getElementById('firstName').classList.add('error');
                </#if>
                <#if messagesPerField.existsError('lastName')>
                    document.getElementById('lastName').classList.add('error');
                </#if>
                <#if messagesPerField.existsError('email')>
                    document.getElementById('email').classList.add('error');
                </#if>
                <#if messagesPerField.existsError('username')>
                    document.getElementById('username').classList.add('error');
                </#if>
                <#if messagesPerField.existsError('password')>
                    document.getElementById('password').classList.add('error');
                </#if>
                <#if messagesPerField.existsError('password-confirm')>
                    document.getElementById('password-confirm').classList.add('error');
                </#if>
            });
        </script>

        <#if recaptchaRequired??>
            <script src="https://www.google.com/recaptcha/api.js" async defer></script>
        </#if>

    </#if>
</@layout.registrationLayout>
