#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "TestProject.generated.h"

UCLASS()
class TESTPROJECT_API ATestProject : public AActor
{
	GENERATED_BODY()
	
public:	
	ATestProject();

protected:
	virtual void BeginPlay() override;

public:	
	virtual void Tick(float DeltaTime) override;

private:
	// Неоптимизированный код для демонстрации
	TArray<int32> MyArray;
	FString ResultString;
	
	// Неэффективный метод
	void InefficientMethod();
	
	// Метод с потенциальной утечкой памяти
	void MemoryLeakMethod();
};
