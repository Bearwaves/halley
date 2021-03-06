#include "entity/entity_factory.h"
#include "halley/halley_entity.h"

#define DONT_INCLUDE_HALLEY_HPP
#include "entity/components/transform_2d_component.h"

using namespace Halley;

EntityFactory::EntityFactory(World& world, Resources& resources)
	: world(world)
	, resources(resources)
{
}

EntityFactory::~EntityFactory()
{
}

EntityRef EntityFactory::createEntity(const ConfigNode& node)
{
	auto entity = world.createEntity();
	const auto func = world.getCreateComponentFunction();

	if (node["components"].getType() == ConfigNodeType::Sequence) {
		for (auto& componentNode: node["components"].asSequence()) {
			for (auto& c: componentNode.asMap()) {
				auto name = c.first;
				func(*this, name, entity, c.second);
			}
		}
	}

	entity.setName(node["name"].asString(""));
	
	if (node["children"].getType() == ConfigNodeType::Sequence) {
		for (auto& childNode: node["children"].asSequence()) {
			createChildEntity(childNode, entity);
		}
	}

	return entity;
}

void EntityFactory::createChildEntity(const ConfigNode& node, EntityRef& parent)
{
	auto e = createEntity(node);

	auto parentTransform = parent.tryGetComponent<Transform2DComponent>();
	if (parentTransform) {
		parentTransform->addChild(e.getComponent<Transform2DComponent>(), true);
	}
}

/*
std::vector<EntityEntry> EntityFactory::createEntityTree(const ConfigNode& node)
{
	const auto& seq = node["entities"].asSequence();
	std::vector<EntityEntry> result;
	result.reserve(seq.size());
	
	for (auto& e: seq) {
		result.push_back(createEntity(e));
	}

	return result;
}
*/