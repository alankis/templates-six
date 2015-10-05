
        </div><!-- /.main-content -->
        {if !$inShoppingCart && $secondarySidebar->hasChildren()}
            <div class="col-md-3 pull-md-left sidebar">
                {include file="$template/includes/sidebar.tpl" sidebar=$secondarySidebar}
            </div>
        {/if}
    </div>
    <div class="clearfix"></div>
</section>


<section id="footer">

    <div class="container">  
        <div class="col20">
            <div class="footer-links">
                <h3>Usluge</h3>
                <ul id="menu-footer-usluge" class="menu">
                    <li class="menu-item"><a href="http://www.infonet.hr/privatni-web-hosting-hr/">Privatni web hosting HR</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/poslovni-web-hosting/">Poslovni web hosting</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/reseller-hosting/">Reseller hosting</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/vps-hosting/">VPS hosting</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/dedicated-hosting/">Dedicated hosting</a></li>
                    <li class="menu-item 9"><a href="http://www.infonet.hr/registracija-domena/">Registracija domena</a></li>
                </ul>
            </div>   
        </div>
        
        <div class="col20">
            <div class="footer-links">
                <h3>Informacije</h3>
                <ul id="menu-footer-informacije" class="menu">
                    <li class="menu-item"><a href="http://www.infonet.hr/o-nama/">O nama</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/google-adwords-promotivna-ponuda/">AdWords promotivna ponuda</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/infonet-serveri/">InfoNET serveri</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/procedura-za-ispravnu-registraciju-hr-domena/">Registracija .hr domena</a></li>
                    <li class="menu-item"><a href="http://korisnik.infonet.hr/announcements.php">Obavijesti</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/r1soft-backup/">R1SOFT enterprise backup</a></li>
                </ul>
            </div>
        </div>

        <div class="col20">
            <div class="footer-links">
                <h3>Pomoć i podrška</h3>
                <ul id="menu-footer-pomoc-i-podrska" class="menu">
                    <li class="menu-item"><a href="http://korisnik.infonet.hr">Korisnička zona</a></li>
                    <li class="menu-item"><a href="http://korisnik.infonet.hr/knowledgebase.php">Baza znanja</a></li>
                    <li class="menu-item"><a href="http://www.infonet.hr/video-tutoriali/">Video tutoriali</a></li>
                    <li class="menu-item"><a href="https://korisnik.infonet.hr/register.php">Registracija korisnika</a></li>
                </ul>
            </div>   
        </div>

        <div class="col20">
            <div class="infonet-info">
                <h3>Informacije</h3>        
                Infonet d.o.o.
                <dl>
                    <dt>Adresa:</dt>
                    <dd>Braće Domany 8, Zagreb</dd>
                    <dt>Telefon:</dt>
                    <dd>tel: 01 3535 030</dd>
                </dl>
            </div>    
        </div>
    </div><!-- end of container -->

    <div class="copyright-info">
        <div class="container">    
                <div class="col70">
                    <ul class="footer-social-links">
                        <li><a target="_blank" class="facebook" href="https://www.facebook.com/pages/InfoNET-hosting/175475552550651"><i class="fa fa-facebook"></i></a></li>
                        <li><a target="_blank" class="twitter" href="https://twitter.com/infonethr"><i class="fa fa-twitter"></i></a></li>
                    </ul>
                    © 2014 InfoNET d.o.o.
                    | <a href="http://www.infonet.hr/uvjeti-koristenja/">Uvjeti korištenja</a> 
                    | <a href="http://www.infonet.hr/ugovor-o-razini-usluge/">Ugovor o razini usluge</a> 
                    | <a href="http://www.infonet.hr/politika-privatnosti/">Politika privatnosti</a> 
                </div>
                <div class="col20">
                    <ul class="footer-payment-links">
                        <li><img src="https://korisnik.infonet.hr/templates/flat/img/payment/maestro.jpg" alt="Maestro"/></li>
                        <li><img src="https://korisnik.infonet.hr/templates/flat/img/payment/mastercard.jpg" alt="MasterCard"/></li>
                        <li><img src="https://korisnik.infonet.hr/templates/flat/img/payment/visa.jpg" alt="Visa"/></li>
                        <li><img src="https://korisnik.infonet.hr/templates/flat/img/payment/paypal.jpg" alt="PayPal"/></li>
                    </ul>
                </div>
        </div>  
    </div>
    <div class="clear"></div>
    

</section>

<script src="{$BASE_PATH_JS}/bootstrap.min.js"></script>
<script src="{$BASE_PATH_JS}/jquery-ui.min.js"></script>
<script type="text/javascript">
    var csrfToken = '{$token}';
</script>
<script src="{$WEB_ROOT}/templates/{$template}/js/whmcs.js"></script>

{$footeroutput}

</body>
</html>
