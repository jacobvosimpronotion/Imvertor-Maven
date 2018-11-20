<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    xmlns:ep="http://www.imvertor.org/schema/endproduct"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    >
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:param name="ep-schema-path">somewhere</xsl:param>
    
    <xsl:variable name="stylesheet-code">EP</xsl:variable>
    <xsl:variable name="debugging" select="imf:debug-mode($stylesheet-code)"/>
    
    <xsl:variable name="domain-packages" select="/imvert:packages/imvert:package[imvert:stereotype/@id = 'stereotype-name-domain-package']"/>
    
    <xsl:template match="/imvert:packages">
        <ep:construct 
            xsi:schemaLocation="http://www.imvertor.org/schema/endproduct {$ep-schema-path}">
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Start hier------------------------------------------------------------------------------------------',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('subpath',imvert:subpath)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="imvert:package"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:package[imvert:stereotype/@id = 'stereotype-name-domain-package']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Domein',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:set-parameter('namespace',imvert:namespace)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="imvert:class"/>
            </ep:seq>
        </ep:construct>
    </xsl:template>
 
    <xsl:template match="imvert:package[imvert:stereotype/@id = 'stereotype-name-external-package']">
        <xsl:variable name="defs" as="node()*">
            <xsl:for-each select="imvert:class">
                <xsl:if test="$domain-packages//*[imvert:conceptual-schema-type = current()/imvert:conceptual-schema-class-name]">
                    <xsl:apply-templates select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="exists($defs)">
            <ep:construct>
                <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Extern package',())"/>
                <ep:parameters>
                </ep:parameters>
                <xsl:sequence select="imf:get-names(.)"/>
                <xsl:sequence select="imf:get-documentation(.)"/>
                <ep:seq>
                  <xsl:sequence select="$defs"/>
                </ep:seq>
            </ep:construct>    
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:package[imvert:stereotype/@id = 'stereotype-name-system-package']">
        <!-- skip -->
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-objecttype']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Objecttype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-supers(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="(imvert:attributes/imvert:attribute, imvert:associations/imvert:association)">
                    <xsl:sort select="imvert:position" data-type="number"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-relatieklasse']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Relatieklasse',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-supers(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="(imvert:attributes/imvert:attribute, imvert:associations/imvert:association)">
                    <xsl:sort select="imvert:position" data-type="number"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-composite']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Gegevensgroeptype',())"/>
            <ep:parameters>
                <xsl:sequence select="imf:get-supers(.)"/>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="(imvert:attributes/imvert:attribute, imvert:associations/imvert:association)">
                    <xsl:sort select="imvert:position" data-type="number"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-union']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Keuze',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:choice>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute"/>
            </ep:choice>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-codelist']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Codelist',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:data-type>ep:string</ep:data-type>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-interface']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Interface (extern)',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:data-type>ep:string</ep:data-type>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-complextype']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een gestructureerd datatype',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:seq>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute">
                    <xsl:sort select="imvert:position" data-type="number"/>
                </xsl:apply-templates>
            </ep:seq>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = 'stereotype-name-simpletype']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een primitief datatype',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-id(.)"/>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <ep:data-type>ep:string</ep:data-type>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-attribute']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een attribuutsoort',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>

    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-attributegroup']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Gegevensgroep',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-union-element']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een keuze element',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:attribute[imvert:stereotype/@id = 'stereotype-name-data-element']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een data element',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
    
    <xsl:template match="imvert:association[imvert:stereotype/@id = 'stereotype-name-relatiesoort']">
        <ep:construct>
            <xsl:sequence select="imf:msg-comment(.,'DEBUG','Een Relatiesoort',())"/>
            <ep:parameters>
            </ep:parameters>
            <xsl:sequence select="imf:get-names(.)"/>
            <xsl:sequence select="imf:get-documentation(.)"/>
            <xsl:sequence select="imf:get-cardinality(.)"/>
            <xsl:sequence select="imf:get-type(.)"/>
        </ep:construct>
    </xsl:template>
    
    <!-- fallback -->
    <xsl:template match="imvert:package">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Unknown package type [1]', imf:string-group(imvert:stereotype/@id))"/>
    </xsl:template>
    <xsl:template match="imvert:class">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Unknown class type [1]', imf:string-group(imvert:stereotype/@id))"/>
    </xsl:template>
    <xsl:template match="imvert:attribute">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Unknown att type [1]',imf:string-group(imvert:stereotype/@id))"/>
    </xsl:template>
    <xsl:template match="imvert:association">
        <xsl:sequence select="imf:msg-comment(.,'WARNING','Unknown association type [1]',imf:string-group(imvert:stereotype/@id))"/>
    </xsl:template>
    
    <xsl:template match="*">
        <xsl:sequence select="imf:msg-comment(.,'ERROR','Unknown element [1]',name(.))"/>
    </xsl:template>
    
    <!--
        FUNCTIONS 
    -->    
    <xsl:function name="imf:get-id" as="element()*">
        <xsl:param name="this"/>
        <ep:id>
            <xsl:value-of select="$this/imvert:id"/>
        </ep:id>
    </xsl:function>
    
    <xsl:function name="imf:get-names" as="element()*">
        <xsl:param name="this"/>
        <ep:name>
            <xsl:value-of select="($this/imvert:name/@original,'UNKNOWN')[1]"/>
        </ep:name>
        <ep:tech-name>
            <xsl:value-of select="($this/imvert:name,'UNKNOWN')[1]"/>
        </ep:tech-name>
    </xsl:function>
    
    <xsl:function name="imf:get-supers" as="element()*">
        <xsl:param name="this"/>
        <xsl:for-each select="$this/imvert:supertype/imvert:type-id">
            <xsl:sequence select="imf:set-parameter('super',.)"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:get-documentation" as="element(ep:documentation)?">
        <xsl:param name="this"/>
        <ep:documentation>
            <ep:definition>
                <ep:p>
                    <xsl:value-of select="imf:get-most-relevant-compiled-taggedvalue($this,'CFG-TV-DEFINITION')"/>
                </ep:p>
            </ep:definition>
        </ep:documentation>
    </xsl:function>
    
    <xsl:function name="imf:get-cardinality" as="element()*">
        <xsl:param name="this"/>
        <ep:min-occurs>
            <xsl:value-of select="($this/imvert:min-occurs,'1')[1]"/>
        </ep:min-occurs>
        <ep:max-occurs>
            <xsl:value-of select="($this/imvert:max-occurs,'1')[1]"/>
        </ep:max-occurs>
    </xsl:function>
    
    <xsl:function name="imf:get-type" as="node()*">
        <xsl:param name="this"/>
        <xsl:choose>
            <xsl:when test="$this/imvert:type-id">
                <ep:ref>
                    <xsl:value-of select="$this/imvert:type-id"/>
                </ep:ref>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-string'">
                <ep:data-type>ep:string</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-date'">
                <ep:data-type>ep:date</ep:data-type>
            </xsl:when>
            <xsl:when test="$this/imvert:type-name = 'scalar-decimal'">
                <ep:data-type>ep:decimal</ep:data-type>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg-comment($this,'WARNING','Unknown (data)type: [1]',($this/imvert:type-name, $this/imvert:baretype)[1])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:set-parameter" as="element(ep:parameter)*">
        <xsl:param name="name"/>
        <xsl:param name="value"/>
        <xsl:if test="normalize-space($value)">
            <ep:parameter>
                <ep:name>
                    <xsl:value-of select="$name"/>
                </ep:name>
                <ep:value>
                    <xsl:value-of select="$value"/>
                </ep:value>
            </ep:parameter>
        </xsl:if>
    </xsl:function>
   
    <xsl:function name="imf:msg-comment">
        <xsl:param name="this" as="node()*"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="info" as="item()*"/>
      
        <xsl:variable name="ctext" select="imf:msg-insert-parms($text,$info)"/>
        <xsl:comment select="concat($type,' : ',imf:get-display-name($this),' : ',$ctext)"/>
       
        <xsl:sequence select="imf:msg($this,$type,$text,$info)"/>
        
    </xsl:function>
</xsl:stylesheet>