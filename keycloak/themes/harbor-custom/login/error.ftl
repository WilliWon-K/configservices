<#import "template.ftl" as layout>

<@layout.registrationLayout displayInfo=true bodyClass="error">
    <h1>Erreur</h1>

    <#if message?has_content>
        <div class="alert">
            ${message.summary}
        </div>
    <#else>
        <div class="alert">
            Une erreur est survenue. Merci de réessayer plus tard.
        </div>
    </#if>

    <p><a href="${url.loginUrl}">Retour à la page de connexion</a></p>
</@layout.registrationLayout>
