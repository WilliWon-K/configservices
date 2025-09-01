<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true displayWide=true; section>
  <#if section = "header">
    Créer un compte
  <#elseif section = "form">
    <div class="overlay-bg"></div>
    <div class="main-layout-harbor">
      <div class="harbor-content">
        <div class="card-pf">
          <div class="custom-header">
            <img src="https://www.semaine-nsi.fr/app/uploads/2024/11/TALAN_logo.jpg" alt="Talan" class="talan-img-large" />
            <div class="custom-title">Inscription Harbor</div>
          </div>

          <form id="kc-register-form" action="${url.registrationAction}" method="post">
            <div class="form-row">
              <div class="form-group">
                <label class="form-label" for="firstName">Prénom</label>
                <input id="firstName" name="firstName" class="form-control" value="${(register.formData.firstName!'')}" required />
              </div>
              <div class="form-group">
                <label class="form-label" for="lastName">Nom</label>
                <input id="lastName" name="lastName" class="form-control" value="${(register.formData.lastName!'')}" required />
              </div>
            </div>

            <div class="form-group">
              <label class="form-label" for="email">Email</label>
              <input id="email" name="email" type="email" class="form-control" value="${(register.formData.email!'')}" required />
            </div>

            <div class="form-group">
              <label class="form-label" for="password">Mot de passe</label>
              <input id="password" name="password" type="password" class="form-control" required />
            </div>

            <div class="form-group">
              <label class="form-label" for="password-confirm">Confirmation du mot de passe</label>
              <input id="password-confirm" name="password-confirm" type="password" class="form-control" required />
            </div>

            <div id="kc-form-buttons">
              <input class="btn" type="submit" value="Créer mon compte" />
              <a href="${url.loginUrl}" class="btn btn-secondary">Retour à la connexion</a>
            </div>
          </form>
        </div>
      </div>
    </div>
  </#if>
</@layout.registrationLayout>
