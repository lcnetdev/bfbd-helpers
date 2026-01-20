<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:marc="http://www.loc.gov/MARC21/slim"
  xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
  xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
  xmlns:lclocal="http://id.loc.gov/ontologies/lclocal/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  extension-element-prefixes="date"
  exclude-result-prefixes="xsl marc">
  
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>
  
  <xsl:variable name="nsmap" select="document('conf/nsmap.xml')"/>
  
  <!-- Template that matches arrays -->
  <xsl:template match="/rdf:RDF">
    <rdf:RDF>
      <xsl:apply-templates select="bflc:SecondaryInstance/bf:instanceOf/bf:Work/bf:hasInstance/bf:Instance | 
                                   bf:Instance |
                                   bf:Work/bf:hasInstance/bf:Instance" />
      <xsl:apply-templates select="bflc:SecondaryInstance" />
      <xsl:apply-templates select="bf:Work | bflc:SecondaryInstance/bf:instanceOf/bf:Work" />
    </rdf:RDF>
  </xsl:template>
  
  <!-- Template that matches map objects -->
  <xsl:template match="bf:Instance">
    <bf:Instance rdf:about="{@rdf:about}">
      <xsl:apply-templates mode="copy" select="*" />
    </bf:Instance>
  </xsl:template>
  
  <xsl:template match="bflc:SecondaryInstance">
    <bf:Instance rdf:about="{@rdf:about}">
      <rdf:type rdf:resource="http://id.loc.gov/ontologies/bflc/SecondaryInstance" />
      <xsl:apply-templates mode="copy" select="*" />
    </bf:Instance>
  </xsl:template>
  
  <xsl:template match="bf:Work">
    <bf:Work rdf:about="{@rdf:about}">
      <xsl:apply-templates mode="copy" select="*" />
    </bf:Work>
  </xsl:template>
  
  <xsl:template mode="copy" match="*">
    <xsl:variable name="ns" select="namespace-uri(.)" />
    <xsl:variable name="ename">
      <xsl:choose>
        <xsl:when test="$nsmap/nsmap/nsm[@ns=$ns]">
          <xsl:value-of select="concat($nsmap/nsmap/nsm[@ns=$ns], ':', local-name(.))"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="name(.)" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- <xsl:message><xsl:value-of select="$ename"/></xsl:message> -->
    <xsl:variable name="rdfresource" select="@rdf:resource" />
    <xsl:choose>
      <xsl:when test="$ename = 'bf:instanceOf' and
                      self::node()/bf:Work/@rdf:about">
        <xsl:element name="{$ename}">
          <xsl:attribute name="rdf:resource"><xsl:value-of select="self::node()/bf:Work/@rdf:about" /></xsl:attribute>
        </xsl:element>    
      </xsl:when>
      <xsl:when test="$ename = 'bf:hasInstance' and
                      not(ancestor::bf:Relation)">
        <xsl:element name="{$ename}">
          <xsl:attribute name="rdf:resource"><xsl:value-of select="self::node()/bf:Instance/@rdf:about" /></xsl:attribute>
        </xsl:element>    
      </xsl:when>
      <xsl:when test="$ename != 'bf:hasInstance' and $ename != 'bf:instanceOf' and
                      $ename != 'bf:hasItem' and $ename != 'bf:itemOf' and
                      @rdf:resource and ancestor::rdf:RDF/descendant::node()[@rdf:about[. = $rdfresource]]">
        <xsl:element name="{$ename}">
          <xsl:apply-templates mode="copy" select="ancestor::rdf:RDF/descendant::node()[@rdf:about[. = $rdfresource]]"/>
        </xsl:element>    
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$ename}">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="text()"/>
          <xsl:apply-templates mode="copy" select="*" />
        </xsl:element>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="copy" match="*[rdf:type/@rdf:resource='http://id.loc.gov/ontologies/bibframe/Note']">
    <xsl:element name="bf:Note">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="text()"/>
      <rdf:type rdf:resource="{concat(namespace-uri(.), local-name(.))}" />
      <xsl:apply-templates mode="copy" select="*[not(rdf:type)]" />
    </xsl:element>
  </xsl:template>
  
  <xsl:template mode="copy" match="*[rdf:type/@rdf:resource='http://id.loc.gov/ontologies/bibframe/VariantTitle']">
    <xsl:element name="bf:VariantTitle">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="text()"/>
      <rdf:type rdf:resource="{concat(namespace-uri(.), local-name(.))}" />
      <xsl:apply-templates mode="copy" select="*[not(rdf:type)]" />
    </xsl:element>
  </xsl:template>
  
  <xsl:template mode="copy" match="*[namespace-uri(.)='http://id.loc.gov/vocabulary/resourceComponents/' and rdf:type/@rdf:resource='http://id.loc.gov/ontologies/bibframe/Work']">
    <xsl:element name="bf:Work">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="text()"/>
      <rdf:type rdf:resource="{concat(namespace-uri(.), local-name(.))}" />
      <xsl:apply-templates mode="copy" select="*[not(rdf:type)]" />
    </xsl:element>
  </xsl:template>
  
</xsl:stylesheet>