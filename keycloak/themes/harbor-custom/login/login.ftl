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
          --error-color: #dc2626;
      }
      html, body { height: 100%; width: 100%; margin: 0; }
      body { font-family: 'Inter', sans-serif; background: url('https://s2.best-wallpaper.net/wallpaper/2880x1800/1706/Port-container-hoist_2880x1800.jpg') center/cover no-repeat; position: relative; }
      .overlay-bg { position: fixed; inset: 0; background: rgba(27,49,75,0.45); z-index: 0; pointer-events: none; }
      .main-layout-harbor { min-height: 100vh; width: 100vw; display: flex; align-items: center; justify-content: center; position: relative; z-index: 1; }
      .harbor-content { display: flex; align-items: center; justify-content: flex-start; min-height: 100vh; width: 100vw; padding-left: 8vw; }
      .card-pf { background: var(--bg-card); border-radius: 32px; box-shadow: var(--shadow-lg); border: 1px solid var(--border); width: 100%; max-width: 420px; padding: 48px 40px 32px 40px; position: relative; display: flex; flex-direction: column; align-items: center; min-width: 320px; overflow: hidden; }
      .card-pf::before { content: ''; position: absolute; top: 0; left: 0; right: 0; height: 14px; background: linear-gradient(90deg, #1b314b 0%, #3a6ea5 60%, #7ec4e4 100%); border-radius: 32px 32px 0 0; z-index: 3; }
      .custom-header { 
        display: flex; 
        flex-direction: column; 
        align-items: center; 
        margin-bottom: 24px; 
        width: 100%; 
      }
      
      .harbor-logo {
        height: 160px; 
        object-fit: contain; 
        display: block;
        border-radius: 8px;
      }
      .mode-switcher { display: flex; background: var(--input-bg); border-radius: 12px; padding: 4px; margin-bottom: 32px; border: 1px solid var(--border); width: 100%; justify-content: center; }
      .mode-btn { flex: 1; padding: 12px 16px; background: transparent; border: none; border-radius: 8px; color: var(--primary); font-size: 14px; font-weight: 500; cursor: pointer; transition: all 0.2s ease; text-align: center; text-decoration: none; display: flex; align-items: center; justify-content: center; }
      .mode-btn.active { background: var(--primary); color: white; font-weight: 600; box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05); }
      .mode-btn:hover:not(.active) { color: var(--text-primary); background: rgba(58, 110, 165, 0.08); }
      .form-group { margin-bottom: 24px; width: 100%; }
      .form-label { display: block; margin-bottom: 8px; color: var(--text-primary); font-size: 14px; font-weight: 500; }
      .form-control { width: 100%; padding: 16px; background: var(--input-bg); border: 1px solid var(--border); border-radius: 12px; font-size: 16px; color: var(--text-primary); transition: all 0.2s ease; box-sizing: border-box; }
      .form-control::placeholder { color: #7ec4e4; }
      .form-control:focus { outline: none; border-color: var(--border-focus); background: var(--input-focus); box-shadow: 0 0 0 3px rgba(58, 110, 165, 0.10); }
      .form-control.error { border-color: var(--error-color); background: #fef2f2; }
      #kc-form-buttons { width: 100%; display: flex; flex-direction: column; align-items: center; gap: 12px; }
      .btn { width: 100%; padding: 16px; background: var(--primary); border: none; border-radius: 12px; color: white; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.2s ease; text-decoration: none; display: inline-block; text-align: center; }
      .btn:hover { background: var(--primary-hover); transform: translateY(-1px); }
      .btn-secondary { background: transparent; color: var(--text-primary); border: 1px solid var(--border); margin-top: 12px; }
      .btn-secondary:hover { background: var(--input-bg); border-color: var(--border-focus); }
      .alert-error { background: #fef2f2; border: 1px solid #fecaca; color: var(--error-color); padding: 12px 16px; border-radius: 8px; margin-bottom: 24px; font-size: 14px; }
      
      /* Responsive */
      @media (max-width: 768px) {
        .harbor-content { padding-left: 5vw; padding-right: 5vw; justify-content: center; }
        .card-pf { max-width: 90vw; padding: 32px 24px; }
        .custom-title { font-size: 1.75rem; }
      }
    </style>

    <div class="overlay-bg"></div>
    <div class="main-layout-harbor">
      <div class="harbor-content">
        <div class="card-pf">
          <div class="custom-header">
            <img src="https://autoize.com/wp-content/uploads/2018/08/harbor-logo.png" alt="Harbor" class="harbor-logo" />
          </div>

          <div class="mode-switcher">
            <button type="button" class="mode-btn active">Connexion</button>
            <a href="${url.registrationUrl}" class="mode-btn">Inscription</a>
          </div>

          <#if message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
            <div class="alert-error">
              ${kcSanitize(message.summary)?no_esc}
            </div>
          </#if>

          <!-- LOGIN FORM ONLY -->
          <form id="kc-form-login" action="${url.loginAction}" method="post">
            <div class="form-group">
              <label class="form-label" for="username">
                <#if !realm.loginWithEmailAllowed>${msg("username")}
                <#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}
                <#else>${msg("email")}
                </#if>
              </label>
              <input id="username" class="form-control" name="username" 
                     value="${(login.username!'')}" type="text" 
                     placeholder="<#if realm.loginWithEmailAllowed>votre.nom@talan.com<#else>nom.utilisateur</#if>" 
                     autofocus 
                     autocomplete="<#if realm.loginWithEmailAllowed>email<#else>username</#if>" />
            </div>
            
            <div class="form-group">
              <label class="form-label" for="password">${msg("password")}</label>
              <input id="password" class="form-control" name="password" type="password" 
                     placeholder="••••••••" autocomplete="current-password" />
            </div>
            
            <#if realm.rememberMe && !usernameEditDisabled??>
              <div class="form-group">
                <label class="checkbox">
                  <input id="rememberMe" name="rememberMe" type="checkbox" 
                         <#if login.rememberMe??>checked</#if> /> 
                  ${msg("rememberMe")}
                </label>
              </div>
            </#if>
            
            <div id="kc-form-buttons">
              <input type="hidden" id="id-hidden-input" name="credentialId" 
                     <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
              <input type="submit" class="btn" value="${msg("doLogIn")}" />
              
              <#if realm.resetPasswordAllowed>
                <a href="${url.loginResetCredentialsUrl}" class="btn btn-secondary">${msg("doForgotPassword")}</a>
              </#if>
            </div>
          </form>

        </div>
      </div>
    </div>

  </#if>
</@layout.registrationLayout>
