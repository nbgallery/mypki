java_import 'javax.crypto.JceSecurity'

# disable SNI since our servers don't support them
java.lang.System.set_property 'jsse.enableSNIExtension', 'false'

# we must remove cryptographic restrictions to communicate 
# with our servers
begin
    isRestricted = JceSecurity.java_class.declared_field 'isRestricted'
    isRestricted.accessible = true
    isRestricted.set_value nil, false
rescue => ex
    warn "Could not remove cryptographic restrictions: #{ex.message}"
end