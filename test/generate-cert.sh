 openssl genrsa -out private.key 4096     && openssl req -new -sha256 \              
    -out private.csr \
    -key private.key \
    -config ssl.conf &&  openssl req -text -noout -in private.cs && openssl x509 -req \                
    -sha256 \             
    -days 3650 \      
    -in private.csr \    
    -signkey private.key \
    -out private.crt \
    -extensions req_ext \
    -extfile ssl.conf
