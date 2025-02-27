<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:UML="omg.org/UML1.3"
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    xmlns:functx="http://www.functx.com"
    
    xmlns:ekf="http://EliotKimber/functions"

    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
  
    <xsl:variable name="schema-defs" select="/imvert:schemas/imvert:schema"/>
  
    <xsl:variable name="xml-schemalocation-approach" select="imf:get-config-xmlschemarules()/parameter[@name='xml-schemalocation-approach']"/>
    
    <xsl:template match="/imvert:schemas">
        
       <!-- 
        each schema has entry in the form: 
        <imvert:schema>
            <imvert:name original="Adres">Adres</imvert:name>
            <imvert:prefix>a</imvert:name>
            <imvert:namespace>http://www.kadaster.nl/schemas/PersoonZoekenEnOpvoeren/CDMKAD-adres/v20150201</imvert:namespace>
            <imvert:result-file-subpath>CDMKAD-adres/v20150201/PersoonZoekenEnOpvoeren_Adres_v1_8_0.xsd</imvert:result-file-subpath>
            <imvert:xsd-path>file:/D:/projects/validprojects/Kadaster-Imvertor/Imvertor-OS-work/default/app/xsd/PersoonZoekenEnOpvoeren/</imvert:xsd-path>
            <imvert:result-file-fullpath>file:/D:/projects/validprojects/Kadaster-Imvertor/Imvertor-OS-work/default/app/xsd/PersoonZoekenEnOpvoeren/CDMKAD-adres/v20150201/PersoonZoekenEnOpvoeren_Adres_v1_8_0.xsd</imvert:result-file-fullpath>
        </imvert:schema>
      -->
       
        <!-- eerst profile naam instellen -->
        <xsl:sequence select="imf:set-xparm('appinfo/gml-profile-name-encoded',encode-for-uri(imf:get-xparm('appinfo/gml-profile-name')))"/>
        
        <imvert:schemas>
            <xsl:apply-templates select="imvert:schema"/>
        </imvert:schemas>  
        
        <!-- and pass the XML schema location approach to the parms. -->
        <xsl:sequence select="imf:set-config-string('appinfo','xml-schemalocation-approach',$xml-schemalocation-approach,true())"/>
        
    </xsl:template>
  
    <xsl:template match="imvert:schema">
        <xsl:copy>
            <xsl:sequence select="*"/>
            <xsl:apply-templates select="xs:schema"/>
        </xsl:copy>
    </xsl:template>
  
    <xsl:template match="imvert:cva">
        <?todo    
        <xsl:result-document href="{$cvafile}" method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
            ...
        </xsl:result-document> 
        ?>
    </xsl:template>
    
    <xsl:template match="xs:schema">
        <xsl:sequence select="imf:track('Processing imports',())"/>
        
        <xsl:variable name="schema" select="."/>
        
        <xsl:variable name="my-qualifier" select="../imvert:prefix"/>
        <xsl:variable name="my-subpath" select="../imvert:result-file-subpath"/>
        <xsl:variable name="my-fullpath" select="../imvert:result-file-fullpath"/>
        <xsl:variable name="is-referencing" select="imf:boolean(../imvert:is-referencing)"/>
      
        <xsl:variable name="qualifiers" as="xs:string*">
            
            <xsl:variable name="uniontokens" select="for $type in .//xs:union/@memberTypes return tokenize($type,'\s+')"/>
            
            <xsl:sequence select="for $qname in .//xs:element/@type return imf:get-prefix($qname)"/>
            <xsl:sequence select="for $qname in .//xs:element/@ref return imf:get-prefix($qname)"/>
            <xsl:sequence select="for $qname in .//xs:element/@substitutionGroup return imf:get-prefix($qname)"/>
            <xsl:sequence select="for $qname in .//xs:attribute/@type return imf:get-prefix($qname)"/>
            <xsl:sequence select="for $qname in .//xs:attribute/@ref return imf:get-prefix($qname)"/>
            <xsl:sequence select="for $qname in .//xs:attributeGroup/@ref return imf:get-prefix($qname)"/>
            <xsl:sequence select="for $qname in .//xs:extension/@base return imf:get-prefix($qname)"/>
            <xsl:sequence select="for $qname in .//xs:restriction/@base return imf:get-prefix($qname)"/>
            <xsl:sequence select="for $qname in $uniontokens return imf:get-prefix($qname)"/>
            
            <xsl:sequence select="for $qname in .//xs:element-stub/@name return imf:get-prefix($qname)"/>
        
            <!-- https://github.com/Imvertor/Imvertor-Maven/issues/48
                this is not required:
                <xsl:sequence select="for $elm in .//xs:appinfo//* return if (contains(name($elm),':')) then imf:get-prefix(name($elm)) else ()"/> 
            -->
        </xsl:variable>
        
        <xsl:variable name="imports" as="node()*">
            <xsl:for-each select="distinct-values($qualifiers)[not(. = $my-qualifier)]">
               
                <xsl:sequence select="imf:create-xml-debug-comment($schema,'qualifier at subpath [1]', ($my-subpath))"/>

                <!-- determine for this prefix which schema is created -->
                <xsl:variable name="prefix" select="."/>
                <xsl:variable name="schema-def" select="$schema-defs[imvert:prefix = $prefix]"/>
                <xsl:variable name="schema-namespace" select="$schema-def[1]/imvert:namespace"/>
                <xsl:variable name="schema-subpath" select="$schema-def[1]/imvert:result-file-subpath"/>
                
                <!-- 
                    The steps to take back to the xsd folder, for all generated model schemas 
                    This is the number of folders in the subpath, and two added folders for application name & release. 
                -->
                <xsl:variable name="steps-back" select="functx:repeat-string('../',count(tokenize($my-subpath,'/')) - 1)"/>     
                
                <xsl:choose>
                    <xsl:when test="$prefix = 'xs'">
                        <!-- native -->
                        <namespace prefix="xs" uri="http://www.w3.org/2001/XMLSchema"/> 
                    </xsl:when>
                    <xsl:when test="$prefix = 'xlink'">
                        <xsl:choose>
                            <xsl:when test="imf:boolean($external-schemas-reference-by-url)">
                                <xs:import namespace="http://www.w3.org/1999/xlink"
                                    schemaLocation="http://schemas.opengis.net/xlink/1.0.0/xlinks.xsd"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xs:import namespace="http://www.w3.org/1999/xlink"
                                    schemaLocation="{$steps-back}xlink/1.0.0/xlinks.xsd"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <namespace prefix="xlink" uri="http://www.w3.org/1999/xlink"/> 
                    </xsl:when>
                    <xsl:when test="count(distinct-values($schema-def/imvert:namespace)) eq 0">
                        <xsl:sequence select="imf:msg('ERROR', 'The qualifier [1] is not associated with a namespace',($prefix))"/>
                    </xsl:when>
                    <xsl:when test="count(distinct-values($schema-def/imvert:namespace)) gt 1">
                        <xsl:sequence select="imf:msg('ERROR', 'The qualifier [1] is associated with multiple namespaces: [2]',($prefix,imf:string-group(distinct-values($schema-def/imvert:namespace))))"/>
                    </xsl:when>
                    <xsl:when test="exists($schema-subpath)">
                        <!-- schema found. This is a generated schema. -->
                        
                        <!-- see https://github.com/Imvertor/Imvertor-Maven/issues/51 -->
                        <xsl:variable name="relative-url" select="concat($steps-back,imf:merge-parms($schema-subpath))"/>
                        <xsl:variable name="absolute-url" select="$schema-def[1]/imvert:result-url"/>
                        
                        <xs:import namespace="{$schema-namespace}" schemaLocation="{if ($xml-schemalocation-approach = 'absolute') then $absolute-url else $relative-url}"/>
                        
                        <xsl:if test="$xml-schemalocation-approach = 'absolute' and not(normalize-space($absolute-url))">
                            <xsl:sequence select="imf:msg('ERROR', 'XML schema locations must be absolute but no URL provided',())"/> <!-- https://github.com/Imvertor/Imvertor-Maven/issues/51 -->
                        </xsl:if>
                        
                        <namespace prefix="{$prefix}" uri="{$schema-namespace}"/> 
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="imf:msg('FATAL', 'The qualifier [1] cannot be mapped onto an application or external schema',$prefix)"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:for-each>
          
        </xsl:variable>
        
        <xsl:result-document href="{$my-fullpath}" method="xml" indent="yes" encoding="UTF-8" exclude-result-prefixes="#all">
            <xsl:variable name="doc">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="$imports[self::namespace]">
                        <xsl:namespace name="{@prefix}" select="@uri"/>
                    </xsl:for-each>
                    <xsl:apply-templates select="xs:annotation"/>
                    <xsl:sequence select="$imports[self::xs:import]"/>
                    <xsl:apply-templates select="node()[empty(self::xs:annotation)]"/>
                </xsl:copy>
            </xsl:variable>
            <xsl:sequence select="if (imf:boolean(imf:get-config-string('cli','cleanupschemas','no'))) then imf:pretty-print($doc,false()) else $doc"/>
        </xsl:result-document>
       
    </xsl:template>
   
    <xsl:template match="xs:element-stub">
        <!-- remove -->
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="imf:get-prefix" as="xs:string">
        <xsl:param name="Qname"/>
        <xsl:variable name="prefix" select="substring-before($Qname,':')"/>
        <xsl:choose>
            <xsl:when test="normalize-space($prefix)">
                <xsl:value-of select="$prefix"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg('ERROR', 'No qualifier found within qualified name [1]',($Qname))"/>     
                <xsl:value-of select="'UNKNOWN'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
