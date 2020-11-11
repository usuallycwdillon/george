package edu.gmu.css.entities;

import com.sun.org.apache.xpath.internal.operations.Bool;
import edu.gmu.css.service.DateConverter;
import org.neo4j.ogm.annotation.*;
import org.neo4j.ogm.annotation.typeconversion.Convert;

import java.util.List;

@NodeEntity
public class Organization extends Entity {
    /**
     *
     */
    @Id
    @GeneratedValue
    Long id;
    @Property @Convert(DateConverter.class)
    Long began;
    @Property @Convert(DateConverter.class)
    Long ended;
    @Property
    String name;
    @Property
    String longname;
    @Property
    String notes;
    @Property
    String cowcode;
    @Property
    String missingData;
    @Property
    Boolean update;


    @Relationship (type = "WITHIN_ORGANIZATION", direction = Relationship.INCOMING)
    protected List<IgoMembershipFact> membershipList;
    @Relationship(type = "FORMED")
    protected IgoFact igoFact;



    public Organization() {

    }

    public Organization(Institution institution) {

    }

    @Override
    public Long getId() {
        return id;
    }

    public Long getBegan() {
        return began;
    }

    public void setBegan(Long began) {
        this.began = began;
    }

    public Long getEnded() {
        return ended;
    }

    public void setEnded(Long ended) {
        this.ended = ended;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getLongname() {
        return longname;
    }

    public void setLongname(String longname) {
        this.longname = longname;
    }



    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getCowcode() {
        return cowcode;
    }

    public void setCowcode(String cowcode) {
        this.cowcode = cowcode;
    }

    public String getMissingData() {
        return missingData;
    }

    public void setMissingData(String missingData) {
        this.missingData = missingData;
    }

    public Boolean getUpdate() {
        return update;
    }

    public void setUpdate(Boolean update) {
        this.update = update;
    }

    public List<IgoMembershipFact> getMembershipList() {
        return membershipList;
    }

    public void setMembershipList(List<IgoMembershipFact> membershipList) {
        this.membershipList = membershipList;
    }

    public IgoFact getIgoFact() {
        return igoFact;
    }

    public void setIgoFact(IgoFact igoFact) {
        this.igoFact = igoFact;
    }
}
