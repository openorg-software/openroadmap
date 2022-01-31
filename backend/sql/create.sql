Begin;

create table roadmap (
	id integer primary key,
	name varchar(32) NOT NULL,
	dayspersprint integer NOT NULL,
	storypointspersprint integer NOT NULL
);

create table milestone(
	id integer primary key,
	name varchar (32) NOT NULL,
	date date NOT NULL
);

create table stakeholder(
	id integer primary key,
	name varchar(32) NOT NULL
);

create table release(
	id integer primary key,
	name varchar(32) NOT NULL,
	dayspersprint integer NOT NULL,
	startdate date NOT NULL,
	targetdate date NOT NULL,
	storypointspersprint integer NOT NULL
);

create table userstory(
	id integer primary key,
	name varchar(32) NOT NULL,
	description varchar(256) NOT NULL,
	storypoints integer NOT NULL,
	priority integer NOT NULL
);

create table discussion(
	id integer primary key,
	content varchar(2097152) NOT NULL
);

create table roadmap_has_stakeholder(
	roadmapid integer,
	stakeholderid integer,
	CONSTRAINT fk_roadmapid
   FOREIGN KEY(roadmapid)
   REFERENCES roadmap(id),
   CONSTRAINT fk_stakeholderid
   FOREIGN KEY(stakeholderid) 
   REFERENCES stakeholder(id)
);

create table roadmap_consistsof_release(
	roadmapid integer,
	releaseid integer,
	CONSTRAINT fk_roadmapid
   FOREIGN KEY(roadmapid)
   REFERENCES roadmap(id),
   CONSTRAINT fk_releaseid
   FOREIGN KEY(releaseid) 
   REFERENCES release(id)
);

create table stakeholder_has_milestone(
	stakeholderid integer,
	milestoneid integer,
	CONSTRAINT fk_stakeholder
   FOREIGN KEY(stakeholderid)
   REFERENCES stakeholder(id),
   CONSTRAINT fk_milestoneid
   FOREIGN KEY(milestoneid) 
   REFERENCES milestone(id)
);

create table stakeholder_has_userstory(
	stakeholderid integer,
	userstoryid integer,
	CONSTRAINT fk_stakeholder
   FOREIGN KEY(stakeholderid)
   REFERENCES stakeholder(id),
   CONSTRAINT fk_userstoryid
   FOREIGN KEY(userstoryid) 
   REFERENCES userstory(id)
);

create table milestone_has_release(
	milestoneid integer,
	releaseid integer,
	CONSTRAINT fk_milestone
   FOREIGN KEY(milestoneid)
   REFERENCES milestone(id),
   CONSTRAINT fk_releaseid
   FOREIGN KEY(releaseid) 
   REFERENCES release(id)
);

create table RELEASE_has_userstory(
	RELEASEid integer,
	userstoryid integer,
	CONSTRAINT fk_RELEASE
   FOREIGN KEY(RELEASEid)
   REFERENCES RELEASE(id),
   CONSTRAINT fk_userstoryid
   FOREIGN KEY(userstoryid) 
   REFERENCES userstory(id)
);

create table userstory_has_discussion(
	userstoryid integer,
	discussionid integer,
	CONSTRAINT fk_userstory
   FOREIGN KEY(userstoryid)
   REFERENCES userstory(id),
   CONSTRAINT fk_discussionid
   FOREIGN KEY(discussionid) 
   REFERENCES discussion(id)
);
COMMIT;