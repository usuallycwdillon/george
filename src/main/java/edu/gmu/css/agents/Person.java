package edu.gmu.css.agents;

import edu.gmu.css.entities.DiscretePolityFact;
import edu.gmu.css.entities.Entity;
import edu.gmu.css.entities.WarParticipationFact;
import edu.gmu.css.relations.KnowsRelation;
import edu.gmu.css.worldOrder.WorldOrder;
import org.neo4j.ogm.annotation.*;
import sim.engine.SimState;
import sim.engine.Steppable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@NodeEntity
public class Person extends Entity implements Steppable {

    @Id
    @GeneratedValue
    private Long id;
    @Property private String name;
    @Property private String address;
    @Property private double bcScore;
    @Property private double ecScore;
    @Property private boolean leadershipRole;
    @Property private String birthplace;
    @Transient private double sentiment;
    @Transient private Map<Entity, Integer> opinions = new HashMap<>();
    @Transient CommonWeal commonWeal;
    @Relationship(type = "KNOWS")
    List<KnowsRelation> circle = new ArrayList<>();
//    @Relationship(type = "RESIDES_IN")



    public Person() {
    }

    public Person(String n) {
        this.name = n;
        this.sentiment = 0.0;
        this.bcScore = 0.0;
        this.leadershipRole = false;
    }


    public void step(SimState simState) {
    }

    @Override
    public Long getId() {
        return id;
    }

    public String getName() {
        return this.name;
    }

    public double getBcScore() {
        return bcScore;
    }

    public void setBcScore(double bcScore) {
        this.bcScore = bcScore;
    }

    public double getEcScore() {
        return ecScore;
    }

    public void setEcScore(double ecScore) {
        this.ecScore = ecScore;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public boolean isLeadershipRole() {
        return leadershipRole;
    }

    public void setLeaderRole(boolean leaderRole) {
        this.leadershipRole = leaderRole;
    }

    public Integer getIssueOpinion(Entity e) {
        return opinions.get(e);
    }

    public void setIssueOpinion(Entity e, int o) {
        opinions.put(e, o);
    }

    public void addIssue(Entity e, int o) {
        opinions.put(e, o);
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBirthplace() {
        return birthplace;
    }

    public void setBirthplace(String birthplace) {
        this.birthplace = birthplace;
    }

    public double getSentiment() {
        return sentiment;
    }

    public void setSentiment(double sentiment) {
        this.sentiment = sentiment;
    }

    public Map<Entity, Integer> getOpinions() {
        return opinions;
    }

    public void setOpinions(Map<Entity, Integer> opinions) {
        this.opinions = opinions;
    }

    public void setCommonWeal(CommonWeal c) {
        this.commonWeal = c;
    }

    public List<Person> getCircle() {
        return circle.stream().map(KnowsRelation::getKnown).collect(Collectors.toList());
    }

    public boolean addToCircle(Person p) {
        this.circle.add(new KnowsRelation(this, p));
        return true;
    }

    public boolean removeFromCircle(Person p) {
        this.circle.remove(p);
        return true;
    }

    public int takeWarOpinion(WarParticipationFact f) {
//        WarParticipationFact fact = f;
        double bt = f.getBattleTrend();
        if (leadershipRole) {
//            double trend = f.getBattleTrend();
            double baseline = commonWeal.getTerritory().getPolity().getSecurityStrategy().getBaseline().getPax();
            if (Math.abs(bt/baseline) < baseline * 0.1) {
                return 0;
            } else if (bt < 0.0) {
                return -1;
            } else {
                return 1;
            }
        } else {
            double satisfaction = commonWeal.getTerritory().getSatisfaction();
            if (satisfaction >= 0.95) {
                return 1;
            } else if (satisfaction < 0.75) {
                return -1;
            } else {
                return 0;
            }
        }
    }

    public void shareOpinion(Entity e, WorldOrder wo) {
        Entity entity = e;
        WorldOrder worldOrder = wo;
        int opinion = opinions.get(entity);
        DiscretePolityFact dp = commonWeal.getLeadership().getPolity().getPolityFact();
        int democracy = dp != null ? dp.getDemocracyRating() + 1 : 2;
        double pChance = worldOrder.random.nextDouble();
        double lChance = (pChance / 11.0) * democracy;
        for (KnowsRelation r : circle) {
            Person friend = r.getKnown();
            int friendOpinion = friend.getIssueOpinion(entity);
            int opinionDiff = Math.abs(opinion - friendOpinion);
            if (leadershipRole && friend.leadershipRole && worldOrder.random.nextBoolean(pChance)) {
                if (opinionDiff == 2) friend.setIssueOpinion(entity, 0);
                if (opinionDiff == 1) friend.setIssueOpinion(entity, opinion);
            } else {
                if (friend.leadershipRole && worldOrder.random.nextBoolean(lChance)) {
                    if (opinionDiff == 2) friend.setIssueOpinion(entity, 0);
                    if (opinionDiff == 1) friend.setIssueOpinion(entity, opinion);
                } else if (!friend.leadershipRole && worldOrder.random.nextBoolean(pChance)) {
                    if (opinionDiff == 2) friend.setIssueOpinion(entity, 0);
                    if (opinionDiff == 1) friend.setIssueOpinion(entity, opinion);
                }
            }
        }
    }

}
