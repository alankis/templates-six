<?php

// set font


// $fontname = $pdf->addTTFfont('/home/devinfonet/public_html/vendor/tecnick.com/tcpdf/fonts/OpenSans-Light.ttf', 'TrueTypeUnicode', '', 32);


if(!class_exists('CUSTOMPDF')){
  class CUSTOMPDF extends TCPDF {

    // Page footer
    public function Footer() {
      global $_LANG;
      $this->SetFont('opensans', '', 7);
      //$this->SetY(-10);
      $footer = '<table class="footer" cellspacing="0" cellpadding="0"><tr><td style="align:center;width:87%">'.$_LANG["infonetfoot"].'</td><td style="text-align:right;width:13%">'.$this->getAliasNumPage().'/'.$this->getAliasNbPages().'</td></tr></table>';
      $this->writeHTML($footer, false, false, false, false, '');

    }
  }
}
$pdf = new CUSTOMPDF();
//$pdf->SetFont($fontname, '', 16,'',FALSE); //Working -- added
//---------------------------------------------------------------------
// BITNO... STANJE RAČUNA
//---------------------------------------------------------------------
$placeno          = ( $status == 'Paid' ? TRUE : FALSE );
$placenoKreditom  = ( $status == 'Kredit' ? TRUE : FALSE ); // linija 225 određuje tekst na pdf-u (POTVRDA K-xxx)


# cached invoices modul
require(ROOTDIR.'/modules/addons/cached_invoices/invoice.php');

# funkcije infonet računa
if (!function_exists('infonet_htmlOutput')){
	require(ROOTDIR.'/modules/addons/infonet_racuni/funkcije.php');
}
# funkcije fiskalizacije - klasa fiskalizacija - DB klasa fiskalDB
if(!class_exists('fiskalizacija')){
	require(ROOTDIR.'/modules/addons/fiskalizacija/functions.php');
}
##############################
#### DEBUGIRANJE VARIJABLI ###
##############################
$debug = FALSE;
if($debug){
	print_r(get_defined_vars());
  //print_r($clientsdetails);
	return; 
}

//---------------------------------------------------------------------
// ZEMLJE EUROPSKE UNIJE  - koristimo za fltriranje tipova korisnika
//---------------------------------------------------------------------
$euzemlje = array("AT",
                  "BE",
                  "BG",
                  "CY",
                  "CZ",
                  "DE",
                  "DK",
                  "EE",
                  "ES",
                  "FI",
                  "FR",
                  "GB",
                  "GR",
                  "HU",
                  "IE",
                  "IT",
                  "LT",
                  "LU",
                  "LV",
                  "MT",
                  "NL",
                  "PL",
                  "PT",
                  "RO",
                  "SE",
                  "SI",
                  "SK"
                  );

$RH           = ( mb_strtoupper($clientsdetails["countrycode"]) == "HR" ? TRUE : FALSE );
$EU           = ( in_array(mb_strtoupper($clientsdetails["countrycode"]), $euzemlje) ? TRUE : FALSE );
$WW           = ( !$RH && !$EU ? TRUE : FALSE );
$OIB          = $clientsdetails["address2"];
$TVRTKA       = $clientsdetails["companyname"];

// Je li riječ o pravnoj osobi? (RH+NAZIVTVRTKE+OIB ili NONRH+NAZIVTVRTKE)
$pravnaosoba = ( ($RH && $OIB && $TVRTKA) || (!$RH && $TVRTKA) ? TRUE : FALSE );




//---------------------------------------------------------------------
// ODREĐIVANJE NAZIVA ATTACHMNENT DATOTEKE
//---------------------------------------------------------------------
$_LANG['invoicefilename'] = ( $placeno ? $_LANG['racunPDFfilenameracun'] : $_LANG['racunPDFfilenameponuda'] );
$_LANG['invoicefilename'] = ( $placenoKreditom ? 'Potvrda' : $_LANG['invoicefilename'] );


//---------------------------------------------------------------------
// PODEŠAVANJE OPCIJA GENERIRANOG PDF-A
//---------------------------------------------------------------------
$pdf->SetMargins(10, 40, 10, true);
$pdf->SetFooterMargin(15);
$pdf->setFooterFont(array('','',9));
$pdf->setFooterData(array(43,55,44), array(255,255,255));
$pdf->SetAutoPageBreak(true,15);
$pdf->setPrintHeader(false);
$pdf->setPrintFooter(true);
$pdf->SetDisplayMode($zoom='real');
$pdf->setViewerPreferences('PrintScaling', 'None');

$pdf->SetFont('opensans','',9,false);
$pdf->setFontSubsetting(FALSE);
$pdf->setCellHeightRatio(1);

$pdf->SetCreator("InfoNET d.o.o. - knjigovodstvo");
$pdf->SetAuthor("InfoNET d.o.o."); 
$pdf->SetTitle("InfoNET d.o.o. - račun: ".$invoicenum);
$pdf->SetSubject("Fiskalni račun za pružene usluge");
$pdf->SetKeywords('InfoNET d.o.o., hosting, domena, račun, ');

//$encoding='ISO-8859-1';
$encoding='UTF-8';



//---------------------------------------------------------------------
// ODREĐIVANJE NAZIVA (PONUDA/RAČUN) I KOREKCIJA FORMATA xx/1/XXXX
//---------------------------------------------------------------------
$invoiceprefix = ( $placeno ? $invoiceprefix = $_LANG["invoicenumber"] : $_LANG["proformainvoicenumber"] ); 
$invoicenum = str_replace("-","/",$invoicenum); // korekcija za format fiskalnog računa zbog buga

# dodatna provjera za ponude plaćene kreditom
$invoiceprefix = ( $placenoKreditom ? 'PREPLATA' : $invoiceprefix ); 


//---------------------------------------------------------------------
// PROVJERA VALUTE I POSTAVLJANJE PREFIXA I SUFIXA - POTPIS
//---------------------------------------------------------------------
$fiskal = new fiskalizacija();
$db = new fiskalDB();
$currency2=$currency;
if($placeno)
  $fiscal = $fiskal->getFiscalByInvoiceID($invoiceid);

$admin = getFullAdmin();
$idklijenta = $userid;
$konverzija = false;
$inorac = 0;
$obrpdv = 0;
$tecaj = 1;
$currsuffix = "Kuna";
$idvalute       = $clientsdetails['currency'];
$formatvalutedef= $db->where('`default`', 1)->getValue('tblcurrencies', 'format');
$formatvalute   = $formatvalutedef;

$kodvalute      =$db->where('id', $idvalute)->getValue('tblcurrencies', 'code'); 
$kodvalutelow   = mb_strtolower($kodvalute);


if ($idvalute>1){
  $formatvalute =	$db->where('code', $kodvalute)->getValue('tblcurrencies', 'format');
  
  $row = $db->where('id',$idvalute)->getOne('tblcurrencies');
  $currrate = $row['rate'];
  $konverzija = true;
  $inorac = 1;
  $tecaj = 1/$currrate;
}

if($placeno){
  $datecreated = $fiscal['date'];
  $datecreated = date("d.m.Y H:i:s",strtotime($datecreated));
}





$duedate2= $duedate;

# uzmi uređaj na koji je vezan gateway i uzmi način plaćanja ( Cash, Bank Account, Credit Card)
$uredaj = $fiskal->getBlagajna($paymentmodule);

$napomenaplacanja = $uredaj['opis_placanja'];
$placanje         = $uredaj['tip_placanja'];

//$signatureImage =$certData['signature'];
$companyName =  $fiskal->companyName; 
$dateSignature = date('d.m.Y H:i:s');
$obi = $fiskal->obiNumber;
$clientid=$userid;


$obv_osnovica= $subtotal;
$obv_porez = $tax;
$potr_osnovica = '0.000000';
$potr_porez = '0.000000';



if ($placanje=="Bank Account"){
  $pri_got = '0.000000';
  $pri_ziro = $total;
} else{
  $pri_got = $total;
  $pri_ziro = '0.000000';
}

if($placeno){
  $fisklaizirani = $db->where('whmcs_invoice', $invoiceid)->getOne('mbit_fiskal_racuni');
  $fiscal_jir= $fisklaizirani['jir'];
  $fiscal_zki = $fisklaizirani['zki'];
  $fiscal_operater = $db->where('id', $fiscal['operaterid'])->getValue('mbit_fiskal_operateri','oznaka');
}



//---------------------------------------------------------------------
// POSTAVKE VARIJABLI BITNIH ZA DIZAJN
//---------------------------------------------------------------------
# format za plaćene račune npr. -> 11.11.2014. u 11:45
$fiskalDatum = substr_replace($datepaid, $_LANG['racunPDFheaderdatumracunadodatak'], 10, 0);

# izgled i tekst, ovisno o stanju ponude/računa
if($placeno || $placenoKreditom) {
  $bojaPolja      = '#69a133';
  if($placenoKreditom)
    $oznakaRacuna   = "POTVRDA K-";
  else
    $oznakaRacuna   = $_LANG['racunPDFheaderracun'];
  $kreiran        = $fiskalDatum;
  $kreiranTekst   = $_LANG['racunPDFheaderdatumracuna'];
}else{
  $bojaPolja      = '#ed1c24';
  $oznakaRacuna   = $_LANG['racunPDFheaderponuda'];
  $kreiran        = $datecreated;
  $kreiranTekst   = $_LANG['racunPDFheaderdatumponude'];
}

# širina dokumenta u mm
$sirinaDokumenta    = $pdf->getPageWidth();
# ispis u headeru - ponuda/račun + broj
$vrstainvoicea      = $oznakaRacuna .''. $invoicenum; 
# ako postoje napomene, treba h dodati iza definiranih napomena u dnu računa
$napomenenaracunu   = ( $notes ? '<br>'.nl2br($notes) : '' );
# podaci o korisniku
$korisnikIme        = '<b>'.ucfirst($clientsdetails["firstname"]).' '.ucfirst($clientsdetails["lastname"]).'</b>';
$korisnikIme        = str_replace('é','e',$korisnikIme);
$korisnikImeHUB        = ucfirst($clientsdetails["firstname"]).' '.ucfirst($clientsdetails["lastname"]);
$korisnikImeHUB        = str_replace('é','e',$korisnikImeHUB);

//$platitelj_comp     = htmlspecialchars_decode( $clientsdetails["companyname"], ENT_QUOTES | ENT_SUBSTITUTE, 'utfmb4' );
$platitelj_comp     = htmlspecialchars_decode( $clientsdetails["companyname"], ENT_COMPAT | ENT_HTML401 );

$platitelj          = ( $pravnaosoba ? mb_strtoupper($platitelj_comp, 'UTF-8') : $korisnikIme );
$platiteljHUB       = ( $pravnaosoba ? mb_strtoupper($platitelj_comp, 'UTF-8') : $korisnikImeHUB );
$adresa             = ucfirst($clientsdetails["address1"]) .'<br>'. $clientsdetails["postcode"].' '.ucfirst($clientsdetails["city"]) . '<br>'. $clientsdetails["country"].'<br><br>';
$custompolja        = "";
if ($customfields) {
  foreach ($customfields AS $customfield) {
    if($customfield['value'] != "")
      $custompolja .= $customfield['fieldname'].': '.$customfield['value'].'<br>';
  } 
}
$oibkorisnika = $clientsdetails["address2"];


//---------------------------------------------------------------------
// HUB-3 BARKOD I POZIV NA BROJ S KONTROLNIM BROJEM ZA MODEL HR01
//---------------------------------------------------------------------
# - poziv na broj s kontrolnim brojem u formatu KORISNIK-PONUDA-DATUM(K)
# - korisnikov ID rezervira 5 znamenaka pa će korisnik br. 134 biti 00134
$pozivnabrojcisti = str_pad($clientsdetails["id"],5,"0",STR_PAD_LEFT).$invoiceid.preg_replace('/[^0-9]+/', '', $datecreated); // ostavlja samo znamenke
$kontrolnibroj    = kontrolniBroj($pozivnabrojcisti); // izračun kontrolnog broja (na dnu predloška)
$pozivnabroj      = str_pad($clientsdetails["id"],5,"0",STR_PAD_LEFT).'-'.$invoiceid.'-'.preg_replace('/[^0-9]+/', '', $datecreated).$kontrolnibroj; // format poziva na broj
$upliznos         = formatirajzaHUB($total, $formatvalute, $tecaj); // iznos za uplatu bez decimala3
$upliznosznam     = (0 - strlen($upliznos)); // broj znamenaka u upaćenom iznosu - oduzima se od definiranih 15 znamenaka za HUB standard
$platadresa       = mb_strtoupper($clientsdetails["address1"], 'UTF-8'); // ulica i broj uplatitelja
$platgrad         = mb_strtoupper($clientsdetails["city"], 'UTF-8'); // grad uplatitelja
$primatelj        = mb_strtoupper($_LANG['tvrtkaNaziv'], 'UTF-8'); // primatelj
$primadresa       = mb_strtoupper($_LANG['tvrtkaAdresa'], 'UTF-8'); // adresa primatelja
$primposta        = mb_strtoupper($_LANG['tvrtkaGrad'], 'UTF-8'); // grad prmatelja
$iban             = mb_strtoupper($_LANG['tvrtkaBrojracuna'], 'UTF-8'); // IBAN primatelja
$opisplacanja     = mb_strtoupper('UPLATA PO PONUDI BROJ '.$invoiceid, 'UTF-8'); // opis plaćanja

# formatiranje polja zageneriranje koda
$HUBkod           = "HRVHUB30";
$HUBvaluta        = "HRK";
$HUBiznos         = substr("000000000000000", 0, $upliznosznam).$upliznos;
$HUBplatitelj     = ukloniHR(( mb_strlen($platiteljHUB) > 30 ? mb_substr(mb_strtoupper($platiteljHUB, 'UTF-8'), 0, 30) : mb_strtoupper($platiteljHUB, 'UTF-8') ));
$HUBadresa        = ukloniHR(( mb_strlen($platadresa) > 27 ? mb_substr($platadresa, 0, 27) : $platadresa ));
$HUBposta         = ukloniHR(( mb_strlen($platgrad) > 27 ? mb_substr($platgrad, 0, 27) : $platgrad ));    
$HUBprimatelj     = ukloniHR(( mb_strlen($primatelj) > 25 ? mb_substr($primatelj, 0, 25) : $primatelj ));
$HUBprimadresa    = ukloniHR(( mb_strlen($primadresa) > 25 ? mb_substr($primadresa, 0, 25) : $primadresa ));
$HUBprimposta     = ukloniHR(( mb_strlen($primposta) > 27 ? mb_substr($primposta, 0, 27) : $primposta ));
$HUBiban          = $iban;
$HUBmodel         = "HR01";
$HUBpoziv         = $pozivnabroj;
$HUBsifranamjene  = "OTHR";
$HUBopisplacanja  = ukloniHR( ( mb_strlen($opisplacanja) > 35 ? mb_substr($opisplacanja, 0, 35) : $opisplacanja ) );

# sadržaj za generiranje barkoda
$HUBDATA = $HUBkod.'
'.$HUBvaluta.'
'.$HUBiznos.'
'.$HUBplatitelj.'
'.$HUBadresa.'
'.$HUBposta.'
'.$HUBprimatelj.'
'.$HUBprimadresa.'
'.$HUBprimposta.'
'.$HUBiban.'
'.$HUBmodel.'
'.$HUBpoziv.'
'.$HUBsifranamjene.'
'.$HUBopisplacanja.'
';


//---------------------------------------------------------------------
// CSS KOD ZA FORMATIRANJE IGLEDA
//---------------------------------------------------------------------

$CSS = <<<EOF
<!-- WHMCS STYLE -->
<style>
h1 { font-size: 22pt; color:#454545}
h1.thin { font-family: opensanslight; font-weight: normal;overflow: visible}
h2 { font-family: opensans; font-weight: bold; font-size: 16pt; text-align:left; color:#333; line-height: 18pt;}
h3 { font-family: opensanslight; font-weight: normal; font-size: 10pt; text-align:left; color:#333; line-height: 13pt;}
p.razmak { font-size: 2pt; line-height: 2pt;}
table.oznaka { width:100%;}
table.oznaka td.prvi{ width:25%; }
table.oznaka td.drugi{ width:28%; font-family: opensanslight; font-weight: normal; font-size: 9pt; text-align:left; color:#333; line-height: 12pt;}
table.oznaka td.treci{ width:47%;}
table.header { border: none; width:100%;}
table.header td.lijevo{ border: none; width:50%;}
table.header td.desno { border: none; font-size: 9pt; line-height:9pt}
table.header td.l { width:30%; font-family: opensans; font-weight: bold;}
table.header td.d { width:20%; font-family: opensanslight; font-weight: normal; color:#454545;}
table.uslugeheader { width:100%; border: none;}
table.uslugeheader td { background-color: $bojaPolja; color: #fff; font-family: opensans; font-weight: bold; font-size:10pt;}
table.uslugeheader td.grupa { background-color: #454545; width: 24%; text-align:left; border-right:5px solid #fff; text-indent:5pt;}
table.uslugeheader td.kolicina { background-color: #454545; width: 11%; text-align:left; border-right:5px solid #fff; text-indent:5pt;}
table.uslugeheader td.opis { width: 52%; text-align:left; border-left:5px solid #fff; border-right:5px solid #fff; text-indent:10pt;}
table.uslugeheader td.cijena { width: 13%; text-align:right; border-left:5px solid #fff;}
table.usluge { width:100%; border:none;}
table.usluge td { background-color: #fff; color: #454545; font-family: opensanslight; font-weight: normal; font-size:10pt;}
table.usluge td.grupa { width: 24%; text-align:left; font-family: opensans; font-weight:bold; font-size:10pt; border-right:10px solid #fff; border-bottom:1pt solid #666666;}
table.usluge td.kolicina { width: 11%; text-align:center; font-family: opensans; font-weight:bold; font-size:10pt; border-right:10px solid #fff; border-bottom:1pt solid #666666;}
table.usluge td.opis { width: 52%; text-align:left;  border-left:10pt solid #fff; border-right:10pt solid #fff; border-bottom:1pt solid $bojaPolja; line-height:12pt;}
table.usluge td.cijena { width: 13%; text-align:right; border-left:10pt solid #fff; border-bottom:1pt solid $bojaPolja;}
table.placanje { width:100%; border:none; color:#454545;}
table.placanje td.lijevo { width: 65%;}
table.placanje td.full {width: 100%;}
table.placanje td.tekst {width: 20%; font-family: opensanslight;font-weight: normal; vertical-align:top;font-size:12pt;text-align:right;}
table.placanje td.cijena {width: 15%; font-family: opensanslight;font-weight: normal; vertical-align:top; font-size:12pt; text-align:right;}
table.transakcije { width:100%; color:#454545;}
table.transakcije td { color:#454545;line-height:20pt}
table.transakcije td.head { border-bottom:2px solid $bojaPolja; color:#454545; font-weight:bold;}
table.transakcije td.obracun { border:none; color:#454545; font-weight:bold}
td.transdno { border-top:1px solid $bojaPolja; color:#454545; font-weight:bold}
p.naplataopis { font-size:10pt; color:#454545; line-height:20pt; border-bottom:1px solid $bojaPolja;}
p.naplataopisful { font-family: opensans; font-weight:bold; font-size:10pt; color:#000; line-height:18pt; border-bottom:1px solid #fff}
p.napomenenaslov { font-family: opensans; font-weight: bold; font-size:10pt; color: $bojaPolja;}
p.napomene { font-family: opensanslight; font-weight: normal; font-size:10pt; color: #666; line-height:12pt; text-align:left;}
p.placanjenaslov { font-family: opensans; font-weight: bold; font-size:10pt; color: $bojaPolja;}
p.placanje {font-family: opensanslight; font-weight: normal; font-size:10pt; color: #454545; line-height:12pt; text-align:left;}
.lowercase { text-transform: lowercase;}
.uppercase { text-transform: uppercase;}
.capitalize {text-transform: capitalize;}
.alignright {text-align:right}
.bold {font-family: opensans;font-weight: bold;}
.bojatekst {color:$bojaPolja}
.racun {color: #7ebb78}
</style>
EOF;



//---------------------------------------------------------------------
// SADRŽAJ RAČUNA - GENERIRANJE
//---------------------------------------------------------------------

# ubaci stranicu, ako ne postoji
if($pdf->getNumPages() == 0) $pdf->AddPage(); 

//---------------------------------------------------------------------
//  DIGITALNI POTPIS RAČUNA - INFO
//---------------------------------------------------------------------
if($placeno){
  // Uzimamo tekst potpisa
  $opcije = opcijeFiskalModula();
  $fiskDatum = substr_replace(date('d.m.Y H:i:s'), $_LANG['racunPDFheaderdatumracunadodatak'], 10, 0);
  $tekstPotpisa = str_replace('{VRIJEME}', $fiskDatum, $opcije['tekst_potpisa']); 
} 


# stanja računa - generiranje se obavlja u printanju Headera - na dnu
if ($status=="Cancelled") {
  $pdf->SetFillColor(200);
  $pdf->SetDrawColor(140);
  $statustext = $_LANG["invoicescancelled"];
} elseif ($status=="Refunded") {
  $pdf->SetFillColor(131,182,218);
  $pdf->SetDrawColor(91,136,182);
  $statustext = $_LANG["invoicesrefunded"];
} elseif ($status=="Collections") {
  $pdf->SetFillColor(3,3,2);
  $pdf->SetDrawColor(127);
  $statustext = $_LANG["invoicescollections"];
}
else {
  $statustext = "";
}



# DETALJI KLIJENTA I PONUDE/RAČUNA U GORNJEM DIJELU
$pdf->SetY(40);

$tbldetaljiKlijenta = $CSS . 
'<table class="header" cellspacing="0" cellpadding="0">
  <tr><td><p class="razmak"> </p><br></td></tr>
  <tr>
  <td class="lijevo"><h2>'.$platitelj.'</h2><h3>'.$adresa.($oibkorisnika ? $_LANG["oib"].$oibkorisnika.'<br>' : '').$custompolja.'</h3>
  </td>

  <td class="desno l alignright"><p>'. $kreiranTekst .':</p>';
if (!$placeno){
  $tbldetaljiKlijenta .= '<p>'. $_LANG['racunPDFheadervrijedido'] .':</p>';
}
$tbldetaljiKlijenta .= ' <p>'. $_LANG['racunPDFheadermjestoizdavanja'] .':</p>';
if ($placeno){
  $tbldetaljiKlijenta .= '<p>'. $_LANG['racunPDFheaderoznakaoperateratxt'] .':</p><p>'. $_LANG['racunPDFheadernacinplacanjatxt'] .':</p>';
}
$tbldetaljiKlijenta .= '<p>'.$_LANG['racunPDFheadervaluta'].':</p></td>
<td class="desno d alignright"><p>'. $kreiran .'</p>';
if (!$placeno){
  $tbldetaljiKlijenta .= '<p>'. $duedate .'</p>';
}
$tbldetaljiKlijenta .= '<p>'. $_LANG['racunPDFheadermjestoizdavanjalokacija'] .'</p>';
if ($placeno){
  $tbldetaljiKlijenta .= '<p>'. $fiscal_operater .'</p><p>'. mb_strtoupper($napomenaplacanja, 'UTF-8') .'</p>';
}
$tbldetaljiKlijenta .= '<p>'.$HUBvaluta.'</p></td></tr><tr><td> </td><td colspan="2" class="desno alignright">'.nl2br($tekstPotpisa).'</td></tr></table>';
$pdf->writeHTML($tbldetaljiKlijenta, false, false, false, false, '');



# POPIS USLUGA I CIJENE
# ----------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------
$y = $pdf->GetY()+5;
$pdf->SetY($y);

// header
$tbluslugeHeader = $CSS .
'<table class="uslugeheader" cellspacing="0" cellpadding="6">
 <tr>
  <td class="grupa">'.ucfirst(mb_strtolower($_LANG['racunPDFuslugetip'])).'</td>
  <td class="kolicina">'.ucfirst(mb_strtolower($_LANG['quantity'], 'UTF-8')).'</td>
  <td class="opis">'.ucfirst(mb_strtolower($_LANG['racunPDFuslugeopis'])).'</td>
  <td class="cijena">'.mb_strtoupper($_LANG['racunPDFuslugeiznos'], 'UTF-8').'</td>
 </tr>
 </table>';
$pdf->writeHTML($tbluslugeHeader,false, false, false, false, '');

// sadržaj
$tblusluge = $CSS;
$brojacRedova = 0;
foreach ($invoiceitems AS $item) 
{
  $itemType = $item['type'];
  $itemID = $item['id'];
  $popustGrupeKorisnika = "";
  $rezultati = $db->rawQuery(
  "SELECT id, (SELECT (
              SELECT (
                SELECT tblproductgroups.name 
                FROM tblproductgroups 
                WHERE id = tblproducts.gid) 
              FROM tblproducts 
              WHERE id = tblhosting.packageid)
            FROM tblhosting 
            WHERE id = tblinvoiceitems.relid) 
  AS imeGrupe 
  FROM tblinvoiceitems WHERE invoiceid='".$invoiceid."' AND type='".$itemType."' AND id ='".$itemID."';"
  ); 

  foreach($rezultati as $rezultat)
  {
    if($rezultat['imeGrupe'] !== NULL)
    { 
      $imeGrupe = $rezultat['imeGrupe'];
      // Malo igranja oko imena proizvoda :-)
      // Uzmi ime proizvoda s računa, do zagrade u kojoj su datumi, u slučaju da je jako kratak naziv
      // Nakon toga skrati string do linije, u slučaju domene i ukloni razmak na kraju stringa
      $imeProizvoda = current(explode("(", $item['description']));
      $imeProizvoda = rtrim(current(explode("-", $imeProizvoda))," ");
      $querySifra = $db->rawQuery("
                    SELECT u.id AS idUsluge 
                    FROM tblproducts u 
                    WHERE u.name = '".$imeProizvoda."' 
                    AND
                    u.gid = (SELECT id FROM tblproductgroups WHERE name = '".$imeGrupe."')
                  ");
      $idUsluge = "-";
      foreach ($querySifra as $red)
      {
        $idUsluge = $red['idUsluge'];
      }
    }
  }
  # AKO GORE NIŠTA NIJE IZVUČENO, TREBA RUČNO ODREDITI GRUPE
  if($itemType=="GroupDiscount"){
    $idUsluge = "-";
    $imeGrupe = $_LANG['orderdiscount'];
    $grupaSQL = $db->rawQuery("
      SELECT groupname AS naziv, discountpercent AS postotak 
      FROM tblclientgroups 
      WHERE id = '".$clientsdetails['groupid']."';"
    );
    foreach($grupaSQL as $rezultatGrupe)
    {
      $nazivGrupeKorisnika = mb_strtoupper($rezultatGrupe['naziv'], 'UTF-8');
      $popustGrupeKorisnika = " " .$rezultatGrupe['postotak']. "%";
      $imeGrupe .= ' - '.$nazivGrupeKorisnika;
    }
  }
  if($itemType=="PromoHosting" || $itemType=="PromoDomain"){
    $idUsluge = "-";
    $imeGrupe = $_LANG['cartpromo'];
  }
  if($itemType=="DomainRegister" || $itemType=="Domain"){
    $idUsluge = "-";
    $imeGrupe = $_LANG['racunPDFdomene'];
  }
  if($itemType=="DomainTransfer" || $itemType=="Domain"){
    $idUsluge = "-";
    $imeGrupe = $_LANG['racunPDFdomene'];
  }
  if($itemType=="Addon"){
    $idUsluge = "-";
    $imeGrupe = $_LANG['racunPDFdodaci'];
  }
  if($itemType=="Upgrade"){
    $idUsluge = "-";
    $imeGrupe = $_LANG['upgradedowngradepackage'];
  }
  if($itemType=="AddFunds"){
    $idUsluge = "-";
    $imeGrupe = $_LANG['addfunds'];
  }
  if($itemType=="MG_DIS_CHARGE"){
    $idUsluge = "-";
    $imeGrupe = $_LANG['racunPDFgatewaytroskovi'];
  }
  if($itemType=="Item" || $itemType==""){
    $idUsluge = "-";
    $imeGrupe = $_LANG['racunPDFrazneusluge'];
  }
  
  // vrijednosti s računa treba prebaciti u kune, ako već nisu! 
  $iznosUsluge = $item['rawamount']; // uzmi već formatirani iznos, bez oznake valute
  $iznosUsluge = formatirajzaprikaz($iznosUsluge, $formatvalutedef, $tecaj);
  if($itemType=="GroupDiscount") $iznosUsluge = '-'.$iznosUsluge; // staviti minus ispred iznosa ako je riječ o grupnom popustu
  
  # formati za valute (decimale)
  # 1 [1234.56]
  # 2 [1,234.56]
  # 3 [1.234,56]
  # 4 [1,234]
  
  
  
  $brojacRedova++;
  
  $tblusluge .= '<table nobr="true" class="usluge" cellspacing="0" cellpadding="6">
  <tr valign="top" style="page-break-inside:avoid;">
    <td valign="top" class="grupa"><p class="razmak"> </p>'.$brojacRedova.'. '.ucfirst($imeGrupe).'</td>
    <td valign="top" class="kolicina"><p class="razmak"> </p>1</td>
    <td valign="top" class="opis"><p class="razmak"> </p>'.nl2br($item['description']).$popustGrupeKorisnika.'<p class="razmak"> </p></td>
    <td valign="top" class="cijena"><p class="razmak"> </p>'.$iznosUsluge.'</td>
  </tr></table>';
  
}	

# ako je kredit u igri, dodajemo popust u popis usluga
if(formatirajzaizracun($credit, $formatvalute) > 0 && formatirajzaizracun($total, $formatvalute) > 0 ) {
  $brojacRedova++;
  
  $creditHRK = formatirajzaizracun($credit, $formatvalute);
  $creditHRK = formatirajzaprikaz($creditHRK, $formatvalutedef, $tecaj);

  $tblusluge .= '<table nobr="true" class="usluge" cellspacing="0" cellpadding="6">
  <tr valign="top" style="page-break-inside:avoid;">
    <td valign="top" class="grupa"><p class="razmak"> </p>'.$brojacRedova.'. Popust</td>
    <td valign="top" class="kolicina"><p class="razmak"> </p>1</td>
    <td valign="top" class="opis"><p class="razmak"> </p>Popust na usluge<p class="razmak"> </p></td>
    <td valign="top" class="cijena"><p class="razmak"> </p>-'.$creditHRK.'</td>
  </tr></table>';

}
$pdf->writeHTML($tblusluge, false, false, false, false, '');


$subtotalHRK = formatirajzaizracun($subtotal, $formatvalute);
$subtotalHRK = formatirajzaprikaz($subtotalHRK, $formatvalutedef, $tecaj);

$creditHRK = formatirajzaizracun($credit, $formatvalute);
$creditHRK = formatirajzaprikaz($creditHRK, $formatvalutedef, $tecaj);

$porezHRK = formatirajzaizracun($tax, $formatvalute);
$porezHRK = formatirajzaprikaz($porezHRK, $formatvalutedef, $tecaj);

$porez2HRK = formatirajzaizracun($tax2, $formatvalute);
$porez2HRK = formatirajzaprikaz($porez2HRK, $formatvalutedef, $tecaj);

# hrvatski idiotizmi s preplatama :)
$kreda = formatirajzaizracun($credit, $formatvalute);
$osnovica = formatirajzaizracun($subtotal, $formatvalute);
$sveukupno = formatirajzaizracun($total, $formatvalute);
$porezPDV = formatirajzaizracun($tax, $formatvalute);

# ukupan iznos je zbroj poreza i osnovice
$novitotal = formatirajzaizracun($tax, $formatvalute) + formatirajzaizracun($subtotal, $formatvalute);

# ako je sve plaćeno kreditom, ukupan iznos mora biti prikazan (nije račun)
# također je zbroj poreza i osnovice
if($kreda > 0.00 && $sveukupno == 0.00 )
  $novitotal = formatirajzaizracun($tax, $formatvalute) + formatirajzaizracun($subtotal, $formatvalute);

# samo djelomična uplata kreditom
# računamo nanovo osnovicu i porez od ukupnog iznosa koji drži samo do plaćen normalnim putem
# samo ako je porez u igri
if($kreda > 0.00 && $sveukupno > 0.00 && $porezPDV > 0.00 ){
  $PDV = $sveukupno * ($taxrate / (100 + $taxrate));
  $PDV = formatirajzaizracun($PDV, $formatvalute);
  $porezHRK = formatirajzaprikaz($PDV, $formatvalutedef, $tecaj);

  $osnovicaPDV = $sveukupno - $PDV;
  $subtotalHRK = formatirajzaprikaz($osnovicaPDV, $formatvalutedef, $tecaj);

  $novitotal = formatirajzaizracun($total, $formatvalute);
}


$kreditopis = ( $creditHRK > 0 ? '<br>'.mb_strtoupper($_LANG['racunPDFuslugekredit'], 'UTF-8') : '' );
$kreditHRK = ( $creditHRK > 0 ? '<br>'.$creditHRK : '' );

$taxnameHRK = ( $porezHRK <> 0 ? '<br>'.mb_strtoupper($taxname, 'UTF-8').' '.$taxrate.'%' : '' );
$taxHRK = ( $porezHRK <> 0 ? '<br>'.$porezHRK : '' );  

$taxname2HRK = ( $porez2HRK <> 0 ? '<br>'.mb_strtoupper($taxname2, 'UTF-8').' '.$taxrate2.'%' : '' );
$tax2HRK = ( $porez2HRK <> 0 ? '<br>'.$porez2HRK : '' );



//$totalHRK = formatirajzaizracun($novitotal, $formatvalute);
$totalHRK = formatirajzaprikaz($novitotal, $formatvalutedef, $tecaj);


# PODACI ZA PLAĆANJE I NAPOMENE
//$napomenavaluta = ( $stranaValuta ? sprintf($_LANG['racunPDFnapomenevaluta'], $kodvalute, $tecajsirovi, $kodvalute) : "" );

$tblPlacanje = $CSS . '<p class="razmak"> </p>
<table nobr="true" class="placanje" cellspacing="0" cellpadding="6">
<tr valign="top" style="page-break-inside:avoid;">
  <td class="lijevo" valign="top"><p class="napomenenaslov">'.$_LANG['racunPDFnapomenenaslov'].'</p>';

if($napomenenaracunu)
  $tblPlacanje .= '<p class="napomene">'.$napomenenaracunu.'</p>';

if($placeno && $fiscal_jir && $fiscal_zki){
  $tblPlacanje .= '<p class="napomene"><strong>JIR:</strong> '.$fiscal_jir. '<br><strong>ZKI: </strong>'.$fiscal_zki.'</p>';
}

$tblPlacanje .= '</td>
  <td class="tekst" valign="top"><p class="naplataopis">'.mb_strtoupper($_LANG['racunPDFuslugeosnovica'], 'UTF-8').$taxnameHRK.$taxname2HRK.'</p>
  <p class="naplataopisful">'.mb_strtoupper($_LANG['racunPDFuslugesveukupno'], 'UTF-8').'</p></td>
  <td class="cijena" valign="top"><p class="naplataopis">'.$subtotalHRK.$taxHRK.$tax2HRK.'</p>
  <p class="naplataopisful">'.$totalHRK.'</p></td></tr></table>';

if(!($placeno || $placenoKreditom))
  $tblPlacanje .= '<table nobr="true" class="placanje" cellspacing="0" cellpadding="6">
<tr valign="top" style="page-break-inside:avoid;">
  <td class="full" valign="top"><p class="placanjenaslov">'.$_LANG['racunPDFplacanjenaslov'].'</p><p class="placanje">'.sprintf($_LANG['racunPDFplacanje'], $pozivnabroj).'</p></td>
</tr>
<tr valign="top" style="page-break-inside:avoid;">
  <td class="full" valign="top"><p class="placanjenaslov">'.$_LANG['racunPDFplacanjeinozemstvonaslov'].'</p><p class="placanje">'.sprintf($_LANG['racunPDFplacanjeinozemstvo'], $pozivnabroj).'</p></td>
</tr>
</table>';


$pdf->writeHTML($tblPlacanje, false, false, false, false, '');

# TRANSAKCIJE
if ($transactions)
{
  $y = $pdf->GetY()+5;
  $pdf->SetY($y);
  $transakcije = $CSS.'
  <table nobr="true" cellspacing="0" cellpadding="0" class="transakcije">
    <tr style="page-break-inside:avoid;">
      <td class="head" width="20%">'.$_LANG['invoicestransdate'].'</td>
      <td class="head" width="37%">'.$_LANG['invoicestransgateway'].'</td>
      <td class="head" width="33%">'.$_LANG['invoicestransid'].'</td>
      <td class="head alignright" width="10%">'.$_LANG['invoicestransamount'].'</td>
    </tr>';

  foreach ($transactions AS $trans) {

    #uzimamo tip plaćanja kao u headeru
    $gatewaycorename = $fiskal->getGatewayByName($trans['gateway']);
    $uredaj = $fiskal->getBlagajna($gatewaycorename);

    $transnapomenaplacanja = $uredaj['opis_placanja'];

    $transakcijaHRK = formatirajzaizracun($trans['amount'], $formatvalute);
    $transakcijaHRK = formatirajzaprikaz($transakcijaHRK, $formatvalutedef, $tecaj);
    $transakcije .= '
      <tr style="page-break-inside:avoid;">
        <td class="mala">'.$trans['date'].'</td>
        <td>'.$transnapomenaplacanja.'</td>
        <td>'.$trans['transid'].'</td>
        <td class="alignright">'.$transakcijaHRK.'</td>
      </tr>';
  }
  
  $stanjeracunaHRK = formatirajzaizracun($balance, $formatvalute);
  $stanjeracunaHRK = formatirajzaprikaz($stanjeracunaHRK, $formatvalutedef, $tecaj);
  $transakcije .= '
    <tr style="page-break-inside:avoid;">
      <td colspan="4" class="alignright obracun">
        <table width="100%" cellspacing="0" cellpadding="0">
          <tr style="page-break-inside:avoid;">
            <td width="75%"> </td>
            <td width="15%" class="transdno alignright"><b>'.$_LANG['invoicesbalance'].'</b></td>
            <td width="10%" class="transdno alignright"><b>'.$stanjeracunaHRK.'</b></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>';
  
  $pdf->writeHTML($transakcije, false, false, false, false, '');
}

$pdf->lastPage();
$brojStranica = $pdf->getPage();
$zadnjahrstranica = $pdf->getPage();
for($int=1;$int <= $brojStranica; $int++){
  $pdf->setPage($int);  

  $pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);
  $pdf->ImageEps(ROOTDIR.'/images/infonetlogo.ai','11','10',42,'','http://infonet.hr');

  $pdf->SetY(5);
  $vrh = $CSS .'<table class="oznaka" cellspacing="0" cellpadding="0">
   <tr>
   <td class="prvi"></td>
   <td class="drugi" valign="top"><b>'.$_LANG['tvrtkaNaziv'].'</b><br>'.$_LANG['tvrtkaAdresa'].'<br>'.$_LANG['tvrtkaGrad'].', '. $_LANG['tvrtkaDrzava'].'<br>'.$_LANG['tvrtkaEmail'].'<br><b>OIB:</b> '.$_LANG['tvrtkaOIB'].'<br><b>PDVID:</b> '.$_LANG['tvrtkaPDVID'].'</td>
   <td class="treci alignright" valign="top"><h1 class="thin alignright">'.$vrstainvoicea.'</h1></td>
   </tr></table>';

  $pdf->writeHTML($vrh, true, false, false, false, '');
  $style2 = array('width' => 0.15, 'cap' => 'butt', 'join' => 'miter', 'dash' => 0, 'color' => array(240, 240, 240));
  $pdf->Line(0, 37, 210, 37, $style2);
  $pdf->write2DBarcode($HUBDATA, 'PDF417,3', 152, 16, 0, 18, $style, 'N');
  
  # oznaka za otkazane i refundirane ponude/račune
  if($statustext){
    $pdf->SetXY(0,0);
    
    $pdf->SetFont('opensans','B',28);
    $pdf->SetTextColor(255);
    $pdf->SetLineWidth(0.75);
    $pdf->StartTransform();
    $pdf->Rotate(-35,100,225);
    if ($status!="Unpaid") $pdf->Cell(100,18,mb_strtoupper($statustext, 'UTF-8'),'TB',0,'C','1');
    $pdf->StopTransform();
    $pdf->SetTextColor(0);
  }
}  

# potpis radi samo ovdje...
if($placeno){
  $pdf->setSignatureAppearance(130, 74, 70, 12 );
  $certifikat = 'file://'.ROOTDIR.'/modules/addons/fiskalizacija/certifikat/tcpdf.crt';
  $info = array(
        'Name' => 'InfoNet d.o.o.',
        'Location' => 'Zagreb',
        'Reason' => 'Elektronicki potpis',
        'ContactInfo' => 'http://www.infonet.hr'
        );
  $pdf->setSignature($certifikat, $certifikat, 'Johnnie23', '', 2, $info);
}
