<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm') displayInfo=social.displayInfo displayWide=true; section>
    <#if section = "header">
        ${msg("registerTitle",(realm.displayName!''))}
    <#elseif section = "form">
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

            :root {
                --sq-blue: #2c3e50;
                --sq-teal: #16a085;
                --sq-light: #ecf0f1;
                --bg-card: #ffffff;
                --border: #bdc3c7;
                --border-focus: #16a085;
                --text-primary: #2c3e50;
                --primary: #16a085;
                --primary-hover: #2c3e50;
                --input-bg: #f7f9fa;
                --input-focus: #ffffff;
                --shadow-lg: 0 10px 15px -3px rgba(44,62,80,0.1);
                --error-color: #e74c3c;
                --success-color: #27ae60;
            }

            html, body { height: 100%; width: 100%; margin: 0; }
            body { font-family: 'Inter', sans-serif; background: url('https://www.sonarqube.org/images/home_bg.jpg') center/cover no-repeat; position: relative; }
            .overlay-bg { position: fixed; inset: 0; background: rgba(44,62,80,0.45); z-index: 0; pointer-events: none; }
            .main-layout-sq { min-height: 100vh; width: 100vw; display: flex; align-items: center; justify-content: center; position: relative; z-index: 1; }
            .sq-content { display: flex; align-items: center; justify-content: center; width: 100%; padding: 0 8vw; }

            .card-pf { background: var(--bg-card); border-radius: 32px; box-shadow: var(--shadow-lg); border: 1px solid var(--border); width: 100%; max-width: 420px; padding: 48px 40px 32px 40px; position: relative; display: flex; flex-direction: column; align-items: center; min-width: 320px; overflow: hidden; }
            .card-pf::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 14px; background: linear-gradient(90deg, #2c3e50 0%, #16a085 60%, #ecf0f1 100%); border-radius: 32px 32px 0 0; z-index: 3; }

            .custom-header { display: flex; flex-direction: column; align-items: center; margin-bottom: 24px; width: 100%; }
            .sq-logo { height: 160px; object-fit: contain; display: block; border-radius: 8px; }

            .mode-switcher { display: flex; background: var(--input-bg); border-radius: 12px; padding: 4px; margin-bottom: 32px; border: 1px solid var(--border); width: 100%; justify-content: center; }
            .mode-btn { flex: 1; padding: 12px 16px; background: transparent; border: none; border-radius: 8px; color: var(--primary); font-size: 14px; font-weight: 500; cursor: pointer; transition: all 0.2s ease; text-align: center; text-decoration: none; display: flex; align-items: center; justify-content: center; }
            .mode-btn.active { background: var(--primary); color: white; font-weight: 600; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); }
            .mode-btn:hover:not(.active) { color: var(--text-primary); background: rgba(22,160,133,0.08); }

            .form-group { margin-bottom: 24px; width: 100%; }
            .form-row { display: flex; gap: 16px; width: 100%; }
            .form-row .form-group { flex: 1; margin-bottom: 24px; }

            .form-label { display: block; margin-bottom: 8px; color: var(--text-primary); font-size: 14px; font-weight: 500; }
            .form-control { width: 100%; padding: 16px; background: var(--input-bg); border: 1px solid var(--border); border-radius: 12px; font-size: 16px; color: var(--text-primary); transition: all 0.2s ease; box-sizing: border-box; }
            .form-control::placeholder { color: #16a085; }
            .form-control:focus { outline: none; border-color: var(--border-focus); background: var(--input-focus); box-shadow: 0 0 0 3px rgba(22,160,133,0.1); }
            .form-control.error { border-color: var(--error-color); background: #fef2f2; }

            #kc-form-buttons { width: 100%; display: flex; flex-direction: column; align-items: center; gap: 12px; }
            .btn { width: 100%; padding: 16px; background: var(--primary); border: none; border-radius: 12px; color: white; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; text-decoration: none; display: inline-block; text-align: center; }
            .btn:hover { background: var(--primary-hover); transform: translateY(-1px); }
            .btn-secondary { background: transparent; color: var(--text-primary); border: 1px solid var(--border); margin-top: 12px; }
            .btn-secondary:hover { background: var(--input-bg); border-color: var(--border-focus); }

            .alert-error { background: #fef2f2; border: 1px solid #e74c3c; color: var(--error-color); padding: 12px 16px; border-radius: 8px; margin-bottom: 24px; font-size: 14px; }
            .password-feedback { font-size: 12px; margin-top: 6px; opacity: 0; transition: opacity 0.2s ease; }
            .password-feedback.show { opacity: 1; }
            .password-feedback.success { color: var(--success-color); }
            .password-feedback.error { color: var(--error-color); }

            .auth-form { display: none; width: 100%; }
            .auth-form.active { display: block; }

            @media (max-width: 768px) {
                .sq-content { padding: 0 5vw; justify-content: center; }
                .card-pf { max-width: 90vw; padding: 32px 24px; }
                .form-row { flex-direction: column; gap: 0; }
            }
        </style>

        <div class="overlay-bg"></div>
        <div class="main-layout-sq">
            <div class="sq-content">
                <div class="card-pf">
                    <div class="custom-header">
                        <img src="https://www.excentia.es/img/sonarsource-products/logo-sonarqube-serve.png" alt="SonarQube" class="sq-logo" />
                    </div>

                    <div class="mode-switcher">
                        <a href="${url.loginUrl}" class="mode-btn">Connexion</a>
                        <button type="button" class="mode-btn active">Inscription</button>
                    </div>

                    <#if messagesPerField.existsError('firstName','lastName','email','username','password','password-confirm')>
                        <div class="alert-error">
                            <#list messagesPerField.get('firstName') as error>${error}<br></#list>
                            <#list messagesPerField.get('lastName') as error>${error}<br></#list>
                            <#list messagesPerField.get('email') as error>${error}<br></#list>
                            <#list messagesPerField.get('username') as error>${error}<br></#list>
                            <#list messagesPerField.get('password') as error>${error}<br></#list>
                            <#list messagesPerField.get('password-confirm') as error>${error}<br></#list>
                        </div>
                    </#if>

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
                                       value="${(register.formData.email!'')}" placeholder="jean.dupont@entreprise.com"
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
                                <a href="${url.loginUrl}" class="btn btn-secondary">Back to login</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function() {
                const newPassword = document.getElementById('password');
                const confirmPassword = document.getElementById('password-confirm');
                const feedback = document.getElementById('password-match');

                if (newPassword && confirmPassword && feedback) {
                    function validatePasswords() {
                        if (confirmPassword.value === '') {
                            feedback.className = 'password-feedback';
                            feedback.innerHTML = '';
                            return;
                        }

                        if (newPassword.value === confirmPassword.value) {
                            if (newPassword.value.length >= 8) {
                                feedback.innerHTML = '✓ Les mots de passe correspondent';
                                feedback.className = 'password-feedback show success';
                            } else {
                                feedback.innerHTML = '⚠ Minimum 8 caractères requis';
                                feedback.className = 'password-feedback show error';
                            }
                        } else {
                            feedback.innerHTML = '✗ Les mots de passe ne correspondent pas';
                            feedback.className = 'password-feedback show error';
                        }
                    }

                    newPassword.addEventListener('input', validatePasswords);
                    confirmPassword.addEventListener('input', validatePasswords);
                }

                // Marquer les champs avec erreurs
                <#if messagesPerField.existsError('firstName')>document.getElementById('firstName').classList.add('error');</#if>
                <#if messagesPerField.existsError('lastName')>document.getElementById('lastName').classList.add('error');</#if>
                <#if messagesPerField.existsError('email')>document.getElementById('email').classList.add('error');</#if>
                <#if messagesPerField.existsError('username')>document.getElementById('username').classList.add('error');</#if>
                <#if messagesPerField.existsError('password')>document.getElementById('password').classList.add('error');</#if>
                <#if messagesPerField.existsError('password-confirm')>document.getElementById('password-confirm').classList.add('error');</#if>
            });
        </script>

        <#if recaptchaRequired??>
            <script src="https://www.google.com/recaptcha/api.js" async defer></script>
        </#if>

    </#if>
</@layout.registrationLayout>
