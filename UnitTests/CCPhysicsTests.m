//
//  CCPhysicsTests.m
//  CCPhysicsTests
//
//  Created by Scott Lembcke on 10/11/13.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"


@interface CCPhysicsTests : XCTestCase

@end


@implementation CCPhysicsTests

static void
TestBasicSequenceHelper(id self, CCPhysicsNode *physicsNode, CCNode *parent, CCNode *node, CCPhysicsBody *body)
{
	// Probably not necessary, but doesn't hurt.
	CCScene *scene = [CCScene node];
	[scene addChild:physicsNode];
	
	// Allow the parent to be the physics node.
	if(parent != physicsNode) [physicsNode addChild:parent];
	
	CGPoint position = node.position;
	float rotation = node.rotation;
	
	const float accuracy = 1e-4;
	
	// Sanity check.
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	[parent addChild:node];
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Set the physics body.
	// Node's internal transform is still used since the onEnter hasn't happened.
	node.physicsBody = body;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
		
	// Force on onEnter to be called.
	// Body's transform is now used instead of the node's.
	[scene onEnter];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Remove the node and check the position is still correct
	[node removeFromParent];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Add back to the physics
	[parent addChild:node];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Force onExit
	[scene onExit];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Force re-entry to the scene.
	[scene onEnter];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Try switching the physics body.
	node.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1 andCenter:ccp(1,1)];
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Test setting the body to nil.
	node.physicsBody = nil;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Set back to the original body
	node.physicsBody = body;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Try setting the body when not added to a scene anymore.
	[node removeFromParent];
	node.physicsBody = nil;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Check that setting the position works in this state.
	node.position = position;
	XCTAssertTrue(ccpDistance(node.position, position) < accuracy, @"");
	XCTAssertEqualWithAccuracy(node.rotation, rotation, accuracy, @"");
	
	// Terrible things happen when you don't call this due to Cocos2D global variables.
	[scene onExit];
}

-(void)testBasicSequences1
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	CCNode *node = [CCNode node];
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences2
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.position = ccp(100, 100);
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences3
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences4
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences5
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, physicsNode, node, body);
}

-(void)testBasicSequences6
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testBasicSequences7
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.position = ccp(20, 60);
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testBasicSequences8
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.contentSize = CGSizeMake(25, 35);
	parent.anchorPoint = ccp(0.3, 0.7);
	parent.position = ccp(20, 60);
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testBasicSequences9
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.contentSize = CGSizeMake(25, 35);
	parent.anchorPoint = ccp(0.3, 0.7);
	parent.position = ccp(20, 60);
	parent.rotation = -10;
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0.5, 0.5);
	node.position = ccp(100, 100);
	node.rotation = 35;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}
	
-(void)testBasicSequences10
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	CCNode *parent = [CCNode node];
	parent.contentSize = CGSizeMake(25, 35);
	parent.anchorPoint = ccp(0.3, 0.7);
	parent.position = ccp(20, 60);
	parent.rotation = -15;
	parent.scaleX = 1.5;
	parent.scaleY = 8.0;
	
	CCNode *node = [CCNode node];
	node.contentSize = CGSizeMake(30, 30);
	node.anchorPoint = ccp(0,0);
	node.position = ccp(100, 100);
	node.rotation = 30;
	node.scaleX = 2.0;
	node.scaleY = 3.0;
	
	CCPhysicsBody *body = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	
	TestBasicSequenceHelper(self, physicsNode, parent, node, body);
}

-(void)testCollisionGroups
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	
	NSString *noCollide = @"nocollide";
	
	CCNode *node1 = [CCNode node];
	node1.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node1.physicsBody.collisionGroup = noCollide;
	[physicsNode addChild:node1];
	
	CCNode *node2 = [CCNode node];
	node2.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node2.physicsBody.collisionGroup = noCollide;
	[physicsNode addChild:node2];
	
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
	
	// Step the physics for a while.
	for(int i=0; i<100; i++){
		[physicsNode fixedUpdate:1.0/60.0];
	}
	
	// Both nodes should be at (0, 0)
	XCTAssertTrue(CGPointEqualToPoint(node1.position, CGPointZero) , @"");
	XCTAssertTrue(CGPointEqualToPoint(node2.position, CGPointZero) , @"");
}

-(void)testAffectedByGravity
{
	CCPhysicsNode *physicsNode = [CCPhysicsNode node];
	physicsNode.gravity = ccp(0, -100);
	
	NSString *noCollide = @"nocollide";
	
	CCNode *node1 = [CCNode node];
	node1.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node1.physicsBody.collisionGroup = noCollide;
	[physicsNode addChild:node1];
	
	CCNode *node2 = [CCNode node];
	node2.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:1.0 andCenter:CGPointZero];
	node2.physicsBody.collisionGroup = noCollide;
	node2.physicsBody.affectedByGravity = NO;
	[physicsNode addChild:node2];
	
	// Force entering the scene to set up the physics objects.
	[physicsNode onEnter];
	
	// Step the physics for a while.
	for(int i=0; i<100; i++){
		[physicsNode fixedUpdate:1.0/60.0];
	}
	
	// Node1 should move down due to gravity
	XCTAssertTrue(node1.position.y < 0.0, @"");
	
	// Node2 should stay at (0, 0)
	XCTAssertTrue(node2.position.y == 0.0, @"");
}

@end
