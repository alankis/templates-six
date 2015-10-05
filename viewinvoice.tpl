{php}
error_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE);

 if (!function_exists('kontrolniBroj')){
          /**
           * Računanje kontrolnog broja za HR01
           * @param mixed $broj 
           * @return double|int
           */
          function kontrolniBroj($broj) {
            $brojznamenaka = strlen($broj);
            $brojac = $brojznamenaka + 1;
            $znamenka = $brojznamenaka-1;
            $reza = 0;
            $ukupno = 0;
            for($i=2;$i<=$brojac;$i++){
              $ukupno += ($i * $broj[$znamenka]);
              $znamenka--;
            }
            $mod = $ukupno % 11;
            $rezultat = $mod;
            if($mod == 1)
              $rezultat = 0;
            if($mod > 1)
              $rezultat = 11 - $mod;
            
            return $rezultat;
          }
        }

        $clientdetails = $template->get_template_vars('clientsdetails');
        $clientid = $clientdetails["id"];
        $invoicedatecreated = $template->get_template_vars('datecreated');
        $invoiceid = $template->get_template_vars('invoicenum');
        $referencenumber = str_pad($clientid, 5, "0", STR_PAD_LEFT).$invoiceid.preg_replace('/[^0-9]+/','', $invoicedatecreated);
        $controlnumber = kontrolniBroj($referencenumber);

        $referencenumberformatted = str_pad($clientid, 5, "0", STR_PAD_LEFT) . '-' . $invoiceid . '-' . preg_replace('/[^0-9]+/','', $invoicedatecreated) . $controlnumber;

        
        $paymentmethod = $template->get_template_vars('paymentmethod');
        if($paymentmethod === "Transakcijski račun")
        {
            $paymentbutton = "Uplata internet bankarstvom ili uplatnicom<br>" . "Poziv na broj: " . "HR01 " . $referencenumberformatted;
            $template->assign('paymentbutton', $paymentbutton);
        }
        $paymentbutton = $template->get_template_vars('paymentbutton');
        $vars = $template->get_template_vars();
{/php}

<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="content-type" content="text/html; charset={$charset}" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$companyname} - {*This code should be uncommented for EU companies using the sequential invoice numbering so that when unpaid it is shown as a proforma invoice*} {if $status eq "Paid"}{$LANG.invoicenumber}{else}{$LANG.proformainvoicenumber}{/if}{$invoicenum}</title>
    <link href='//fonts.googleapis.com/css?family=Source+Sans+Pro:200,300,400,700' rel='stylesheet' type='text/css'>
    <link href="templates/{$template}/css/bootstrap-invoice.min.css" rel="stylesheet">
    <link href="templates/{$template}/css/invoice.css" rel="stylesheet">
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-md-12">    
                <div class="panel panel-default">
                    <div class="panel-heading">
                        {if $error}
                        <div class="alert alert-danger">{$LANG.invoiceserror}</div>
                        {else}
                        <div class="row">
                            <div class="col-sm-6">
                                {if $logo}<p><img class="invoice-logo"src="{$logo}" title="{$companyname}" /></p>{else}<h2>{$companyname}</h2>{/if}
                            </div>
                            <div class="col-sm-6 text-right">
                                {if $status eq "Unpaid"}
                                <p><span class="label label-danger">{$LANG.invoicesunpaid}</span></p>
                                {if $allowchangegateway}
                                <form method="post" class="hidden-print" action="{$smarty.server.PHP_SELF}?id={$invoiceid}">{$gatewaydropdown}</form>
                                {else}
                                {$paymentmethod}
                                {/if}
                                <div class="hidden-print" style="float:right; margin-top:5px;">{$paymentbutton}</div>
                                {elseif $status eq "Paid"}
                                <p><span class="label label-success">{$LANG.invoicespaid}</span></p>
                                {$paymentmethod}
                                ({$datepaid})
                                {elseif $status eq "Refunded"}
                                <p><span class="label label-info">{$LANG.invoicesrefunded}</span></p>
                                {elseif $status eq "Cancelled"}
                                <p><span class="label label-info">{$LANG.invoicescancelled}</span></p>
                                {elseif $status eq "Collections"}
                                <p><span class="label label-info">{$LANG.invoicescollections}</span></p>
                                {/if}
                            </div>
                        </div>
                        {if $smarty.get.paymentsuccess}
                        <p class="paid">{$LANG.invoicepaymentsuccessconfirmation}</p>
                        {elseif $smarty.get.pendingreview}
                        <p class="paid">{$LANG.invoicepaymentpendingreview}</p>
                        {elseif $smarty.get.paymentfailed}
                        <p class="unpaid">{$LANG.invoicepaymentfailedconfirmation}</p>
                        {elseif $offlinepaid}
                        <p class="refunded">{$LANG.invoiceofflinepaid}</p>
                        {/if}
                    </div>
                    <div class="panel-body">
                        {if $manualapplycredit}
                        
                        <form  method="post" action="{$smarty.server.PHP_SELF}?id={$invoiceid}">
                         <div class="row">
                            <div class="col-md-6 col-md-offset-3">
                                <div class="well well-sm well-white clearfix">    
                                    <h4>{$LANG.invoiceaddcreditdesc1}: <span class="label label-success pull-right">{$totalcredit}</span></h4>

                                    <input type="hidden" name="applycredit" value="true" />
                                    <div class="input-group">
                                    <input type="text" class="form-control input-sm" name="creditamount" value="{$creditamount}" />
                                        <span class="input-group-btn">
                                            <input type="submit" class="btn btn-default" value="{$LANG.invoiceaddcreditapply}" />                                                
                                        </span>
                                    </div>
                                    <p class="help-block"><small>{$LANG.invoiceaddcreditamount}.</small></p>     
                                </div>  
                            </div>  
                        </div>
                    </form>                                               

                    {/if}
                    <div class="row">
                        <div class="col-xs-4">
                            <h4>{if $status eq "Paid"}{$LANG.documentinvoice}<strong>{$invoicenum}</strong> po ponudi {$invoiceid}{else}{$LANG.proformainvoicenumber}{$invoicenum}{/if}</h4>
                            <p>{$LANG.invoicesdatecreated}: {$datecreated}<br>
                                {$LANG.invoicesdatedue}: {$datedue}</p>
                                <div class="btn-group" role="group">
                            <a href="dl.php?type=i&amp;id={$invoiceid}" class="btn btn-primary">
                                {if $status eq "Paid"}{$LANG.paidinvoicesdownload}{else}{$LANG.invoicesproformadownload}{/if}</a> 
                        </div>
                            </div>
                            <div class="col-xs-4">
                                <h4>{$LANG.invoicesinvoicedto}</h4>
                                <p>
                                    {if $clientsdetails.companyname}{$clientsdetails.companyname}<br>{/if}
                                    {$clientsdetails.firstname} {$clientsdetails.lastname}<br>
                                    {$clientsdetails.address1}, {$clientsdetails.address2}<br>
                                    {$clientsdetails.city}, {$clientsdetails.state}, {$clientsdetails.postcode}<br>
                                    {$clientsdetails.country}
                                    {if $customfields}
                                    <p>
                                        {foreach from=$customfields item=customfield}
                                        {$customfield.fieldname}: {$customfield.value}<br>
                                        {/foreach}
                                        <p>
                                            {/if}
                                        </p>
                                    </div>
                                    <div class="col-xs-4">
                                        <h4>{$LANG.invoicespayto}</h4>
                                        <p>{$payto}</p>
                                    </div>
                                </div>
                                <table class="table table-striped">
                                    <tr>
                                        <td><h4>{$LANG.invoicesdescription}</h4></td>
                                        <td class="text-right"><h4>{$LANG.invoicesamount}</h4></td>
                                    </tr>
                                    {foreach from=$invoiceitems item=item}
                                    <tr>
                                        <td>{$item.description}{if $item.taxed eq "true"} *{/if}</td>
                                        <td class="text-right">{$item.amount}</td>
                                    </tr>
                                    {/foreach}
                                    <tr>
                                        <td>{$LANG.invoicessubtotal}:</td>
                                        <td class="text-right">{$subtotal}</td>
                                    </tr>
                                    {if $taxrate}
                                    <tr>
                                        <td>{$taxrate}% {$taxname}:</td>
                                        <td class="text-right">{$tax}</td>
                                    </tr>
                                    {/if}
                                    {if $taxrate2}
                                    <tr>
                                        <td>{$taxrate2}% {$taxname2}:</td>
                                        <td class="text-right">{$tax2}</td>
                                    </tr>
                                    {/if}
                                    <tr>
                                        <td>{$LANG.invoicescredit}:</td>
                                        <td class="text-right">{$credit}</td>
                                    </tr>
                                    <tr class="info">
                                        <td><h4>{$LANG.invoicestotal}:</h4></td>
                                        <td class="text-right"><h4>{$total}</h4></td>
                                    </tr>
                                </table>
                                {if $taxrate}<p>* {$LANG.invoicestaxindicator}</p>{/if}
                                <h4>{$LANG.invoicestransactions}</h4>
                                <div class="table-responsive">
                                    <table class="table table-striped">
                                        <tr>
                                            <td>{$LANG.invoicestransdate}</td>
                                            <td>{$LANG.invoicestransgateway}</td>
                                            <td>{$LANG.invoicestransid}</td>
                                            <td class="text-right">{$LANG.invoicestransamount}</td>
                                        </tr>
                                        {foreach from=$transactions item=transaction}
                                        <tr>
                                            <td>{$transaction.date}</td>
                                            <td>{$transaction.gateway}</td>
                                            <td>{$transaction.transid}</td>
                                            <td class="text-right">{$transaction.amount}</td>
                                        </tr>
                                        {foreachelse}
                                        <tr>
                                            <td colspan="4">{$LANG.invoicestransnonefound}</td>
                                        </tr>
                                        {/foreach}
                                        <tr class="info">
                                            <td colspan="3">{$LANG.invoicesbalance}:</td>
                                            <td class="text-right">{$balance}</td>
                                        </tr>
                                    </table>
                                </div>
                                {if $notes}
                                <p>{$LANG.invoicesnotes}: {$notes}</p>
                                {/if}
                                {/if}
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 text-center hidden-print">
                        <div class="btn-group" role="group">
                            <a href="clientarea.php" class="btn btn-default">{$LANG.invoicesbacktoclientarea}</a> <a href="dl.php?type=i&amp;id={$invoiceid}" class="btn btn-default ">{if $status eq "Paid"}{$LANG.paidinvoicesdownload}{else}{$LANG.invoicesproformadownload}{/if}</a> <a href="javascript:window.close()" class="btn btn-default btn-danger">{$LANG.closewindow}</a>
                        </div>
                    </div>
                </div>
            </div>
        </body>
        </html>