#!/bin/sh
wget -nc https://media.githubusercontent.com/media/Possiblehealth/possible-artifacts/master/92-artifacts/insurance-integration-0.0.1-1.noarch.rpm
rpm -ivh insurance-integration-0.0.1-1.noarch.rpm
psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'insurance'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE insurance"
echo "Database Created"
sed -i '/imisconnect.errortrace.include=true/d' /etc/insurance-integration/insurance-integration.properties
sed -i '/imisconnect.claimresource.save=true/d' /etc/insurance-integration/insurance-integration.properties
sed -i '/imisconnect.eligresource.save=false/d' /etc/insurance-integration/insurance-integration.properties
sed -i '/openimis.enterer.id=/d' /etc/insurance-integration/insurance-integration.properties
sed -i '/openimis.healthFacility.id=/d'  /etc/insurance-integration/insurance-integration.properties  
sed -i '/openimis.policy.enabled=true/d' /etc/insurance-integration/insurance-integration.properties
sed -i '/openimis.fhir.api.elig=/d' /etc/insurance-integration/insurance-integration.properties 
sed -i '/ openimis.fhir.api.claim=/d' /etc/insurance-integration/insurance-integration.properties 
sed -i '1i\ imisconnect.errortrace.include=true' /etc/insurance-integration/insurance-integration.properties
sed -i '2i\ imisconnect.claimresource.save=true' /etc/insurance-integration/insurance-integration.properties
sed -i '3i\ imisconnect.eligresource.save=false' /etc/insurance-integration/insurance-integration.properties
sed -i '4i\ openimis.enterer.id=' /etc/insurance-integration/insurance-integration.properties
sed -i '5i\ openimis.healthFacility.id=' /etc/insurance-integration/insurance-integration.properties
sed -i '6i\ openimis.policy.enabled=true' /etc/insurance-integration/insurance-integration.properties
sed -i '7i\ openimis.fhir.api.elig=' /etc/insurance-integration/insurance-integration.properties
sed -i '8i\ openimis.fhir.api.claim=' /etc/insurance-integration/insurance-integration.properties
wget -nc https://raw.githubusercontent.com/Possiblehealth/possible-artifacts/master/92-artifacts/imisintegration-0.0.1-SNAPSHOT.omod
mv -vn imisintegration-0.0.1-SNAPSHOT.omod /opt/openmrs/modules/
service openmrs restart
service openmrs status
mkdir -p /opt/bahmni-insurance-addons/ 
cd /opt/bahmni-insurance-addons/
git clone https://github.com/Bahmni/bahmni_insurance_odoo.git
cd /opt/bahmni-insurance-addons/bahmni_insurance_odoo
git checkout develop
echo "Script Ran Successfully"
echo "Add below configuration manually"
echo "Change required  configuration /etc/insurance-integration/insurance-integration.properties" 
echo "### Change ip for odoo and fhir server ###"
echo "Goto /etc/odoo.conf"
echo "Add location of bahmni insurance module in addons-section as"
echo "addons_path = /opt/bahmni-erp/bahmni-addons,/opt/bahmni-erp/odoo/addons,/usr/lib/python2.7/site-packages,/opt/bahmni-insurance-addons/"
sed -i '/addons_path =/d' /etc/odoo.conf	
ex -s -c '8i|addons_path = /opt/bahmni-erp/bahmni-addons,/opt/bahmni-erp/odoo/addons,/usr/lib/python2.7/site-packages,/opt/bahmni-insurance-addons/' -c x /etc/odoo.conf
service odoo restart
touch /etc/httpd/conf.d/insurance_integration_ssl.conf
sed -i '/#for insurance-int/d' /etc/httpd/conf.d/insurance_integration_ssl.conf
sed -i '/ProxyPass/d' /etc/httpd/conf.d/insurance_integration_ssl.conf
sed -i '/ProxyPassReverse/d' /etc/httpd/conf.d/insurance_integration_ssl.conf
echo " #for insurance-int" >> /etc/httpd/conf.d/insurance_integration_ssl.conf
echo "ProxyPass /insurance-integration http://localhost:8092/insurance-integration/" >>/etc/httpd/conf.d/insurance_integration_ssl.conf  
echo "ProxyPassReverse /insurance-integration http://localhost:8092/insurance-integration/" >>/etc/httpd/conf.d/insurance_integration_ssl.conf
service httpd restart


